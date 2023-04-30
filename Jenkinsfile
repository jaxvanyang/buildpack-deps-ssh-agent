pipeline {
	options {
		disableConcurrentBuilds()
		buildDiscarder logRotator(artifactDaysToKeepStr: '', artifactNumToKeepStr: '', daysToKeepStr: '30', numToKeepStr: '')
	}
	agent {
		label 'built-in'
	}
	stages {
		stage('Clean Old Build') {
			steps {
				sh 'make clean'
			}
		}
		// Images are not changed for a long time
		// stage('Pull Images') {
		// 	steps {
		// 		sh 'make pull'
		// 	}
		// }
		stage('Docker Deploy Matrix') {
			matrix {
				axes {
					axis {
						name 'TAG'
						values 'amd64-sid', 'riscv64-sid', 'arm64v8-sid'
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
		// stage('VM Deploy Matrix') {
		// 	matrix {
		// 		axes {
		// 			axis {
		// 				name 'TAG'
		// 				values 'amd64-sid', 'arm64v8-sid'
		// 			}
		// 		}
		// 		stages {
		// 			stage('Deploy') {
		// 				steps {
		// 					echo "Deploy ${TAG}-vm"
		// 					sh 'make ${TAG}-vm'
		// 				}
		// 			}
		// 			stage('Test') {
		// 				steps {
		// 					echo "Test ${TAG}-vm"
		// 					sh 'virsh desc ${TAG}-vm'
		// 				}
		// 			}
		// 		}
		// 	}
		// }
	}
}

// vim: ft=groovy
