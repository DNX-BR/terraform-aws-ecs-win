<powershell>
echo "### SETUP AGENT"
Initialize-ECSAgent -Cluster ${tf_cluster_name} -EnableTaskIAMRole -LoggingDrivers '["json-file","awslogs"]'
[Environment]::SetEnvironmentVariable("ECS_ENABLE_AWSLOGS_EXECUTIONROLE_OVERRIDE",$TRUE,"Machine")
[Environment]::SetEnvironmentVariable("ECS_ENABLE_TASK_ENI",$TRUE,"Machine")

echo "### EXTRA USERDATA"
${userdata_extra}
</powershell>
