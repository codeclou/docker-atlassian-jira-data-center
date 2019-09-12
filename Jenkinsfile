sh 'curl -sSLko pipeline-helper.groovy ${K8S_INFRASTRUCTURE_BASE_URL}pipeline-helper/pipeline-helper.groovy?v2'
def pipelineHelper = load("./pipeline-helper.groovy")
pipelineHelper.jenkinsDiscardOldBuilds(10)
pipelineHelper.jenkinsDisableConcurrentBuilds()
def hasLoadbalancerChanged = false
pipelineHelper.deployTemplate {
    stage('clone') {
        sh 'rm -rf source | true'
        sh 'git clone --single-branch --branch $GWBT_BRANCH$GWBT_TAG https://${SECRET_GITHUB_AUTH_TOKEN}@github.com/${GWBT_REPO_FULL_NAME}.git source'
        dir('source') {
            sh 'git reset --hard $GWBT_COMMIT_AFTER'

            def gitCheck = sh (script: 'git show ' + env.GWBT_COMMIT_AFTER + ' | grep -e \'/loadbalancer/\' | wc -l', returnStdout: true).trim()
            if (gitCheck != "0") {
                hasLoadbalancerChanged = true
            }
        }
    }
    stage('build & push docker image') {
      dir('source') {
        if (hasLoadbalancerChanged) {
            echo "LOADBALANCER HAS CHANGED - DO BUILD"
            dir('loadbalancer') {
                def shortCommitId = env.GWBT_COMMIT_AFTER.substring(0, 7)
                echo "shortCommit: " + shortCommitId
                sh 'docker login -u codeclou -p ${SECRET_DOCKERHUB_CODECLOU_PASSWORD}'
                sh 'docker build . -t codeclou/' + env.GWBT_REPO_NAME + ':loadbalancer-' + shortCommitId
                sh 'docker push codeclou/' + env.GWBT_REPO_NAME + ':loadbalancer-' + shortCommitId
            }
        } else {
            echo "LOADBALANCER HAS NOT CHANGED - DO NOTHING"
        }        
      }
    }
}
