SONAR_TOKEN="a121f9c444947687c9b2afbc49c9974a1220ffe2"
TASK_ID=$(curl -s -u "${SONAR_TOKEN}:" "https://sonarcloud.io/api/ce/activity" | jq -r '.tasks[0].analysisId')

if [ -z "${TASK_ID}" ]; then
    echo "Error al obtener el ID de la tarea. Deteniendo el pipeline."
    exit 1
fi

QG_STATUS=$(curl -s -u "${SONAR_TOKEN}:" "https://sonarcloud.io/api/qualitygates/project_status?analysisId=${TASK_ID}" | jq -r '.projectStatus.status')
echo ${QG_STATUS}
if [ "${QG_STATUS}" = "ERROR" ]; then
    echo "Quality Gate failed. Stopping the pipeline."
    exit 1
fi