QG_STATUS=$(curl https://sonarcloud.io/api/qualitygates/project_status\?projectKey\=maiglesias_NodeGoat | jq -r '.projectStatus.status')

if [ ${QG_STATUS} == "ERROR" ]; then
    echo "Quality Gate failed. Stopping the pipeline."
fi