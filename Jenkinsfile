pipeline {
	agent {
		label 'fx50j-arch'
	}

	stages {
		stage('Clean Old Build') {
			steps {
				sh 'make clean'
			}
		}
		stage('Matrix') {
			axes {
				axis {
					name 'TAG'
					values 'amd64-sid', 'riscv64-sid'
				}
			}
			stages {
				stage('Build ${TAG}') {
					steps {
						sh 'make ${TAG}'
					}
				}
				stage('Deploy ${TAG}-agent') {
					steps {
						sh 'make ${TAG}-agent'
					}
				}
				stage('Test ${TAG}-agent') {
					steps {
						sh 'docker exec ${TAG}-agent uname -a'
					}
				}
			}
		}
	}
}

// vim: ft=groovy
