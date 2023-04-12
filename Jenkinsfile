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
					stage('Deploy') {
						steps {
							echo "Deploy ${TAG}-agent"
							sh 'make ${TAG}-agent'
						}
					}
					stage('Test') {
						steps {
							echo "Test ${TAG}-agent"
							sh 'docker exec ${TAG}-agent uname -a'
						}
					}
				}
			}
		}
	}
}

// vim: ft=groovy
