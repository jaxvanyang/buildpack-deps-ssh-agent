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
		stage('Pull Images') {
			steps {
				sh 'make pull'
			}
		}
		stage('Matrix') {
			matrix {
				axes {
					axis {
						name 'TAG'
						values 'amd64-sid', 'riscv64-sid'
					}
				}
				stages {
					stage('Deploy ' + env.TAG + '-agent') {
						steps {
							sh 'make ${TAG}-agent'
						}
					}
					stage('Test ' + env.TAG + '-agent') {
						steps {
							sh 'docker exec ${TAG}-agent uname -a'
						}
					}
				}
			}
		}
	}
}

// vim: ft=groovy
