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
				sh '''docker run -d \
				-v docker-volume-for-amd64-sid-agent:/home/jenkins/agent:rw \
				-p 2200:22 \
				--name amd64-sid-agent --restart on-failure:5 \
				buildpack-deps-ssh-agent:sid \
				"${JENKINS_AGENT_SSH_PUBKEY}"
				'''
			}
		}
		stage('Test amd64-sid-agent') {
			steps {
				sh 'ssh -p 2200 jenkins@localhost uname -a'
			}
		}
	}
}

// vim: ft=groovy
