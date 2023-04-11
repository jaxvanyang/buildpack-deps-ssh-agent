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
		stage('Build amd64-sid') {
			steps {
				sh 'make amd64-sid'
			}
		}
		stage('Deploy amd64-sid-agent') {
			steps {
				sh 'make amd64-sid-agent'
			}
		}
		stage('Test amd64-sid-agent') {
			steps {
				sh 'docker exec amd64-sid-agent uname -a'
			}
		}
	}
}

// vim: ft=groovy
