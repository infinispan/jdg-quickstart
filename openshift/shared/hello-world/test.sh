#!/usr/bin/env bash

set -e

readonly PROGNAME=$(basename $0)
readonly ARGS="$@"
SERVICE_NAME="cache-service"

usage() {
	cat <<- EOF
	usage: $PROGNAME options

	Builds, deploys and tests the quickstart and associated services on OpenShift.

	OPTIONS:
		-c --clean               delete the services and quickstart from OpenShift.
		-h --help                show this help.
		-p --cross-project       deploys and tests services and quickstarts in different OpenShift namespaces.
		-q --quickstart-only     only test the quickstart, it assumes the service is running.
		-s --service-name        service to test, can be either cache-service or datagrid-service.
		                         cache-service is default.
		-x --debug               debug


	Examples:
		Test quickstart on cache-service:
		$PROGNAME

		Only tests quickstart, assumes service is already running:
		$PROGNAME --quickstart-only

		Clean and remove quickstart and cache-service deployment:
		$PROGNAME --clean

		Test quickstart on datagrid-service:
		$PROGNAME --service-name datagrid-service

		Clean and remove quickstart and datagrid-service deployment:
		$PROGNAME --clean --service-name datagrid-service

		Starts cache-service and tests that quickstart can interact with it when deployed in separate namespace:
		$PROGNAME --cross-project

		Tests that quickstart can interact with it when deployed in separate namespace:
		$PROGNAME --cross-project --quickstart-only

		Run with extra logging:
		$PROGNAME --debug
	EOF
}

cmdline() {
    local arg=
    for arg
    do
        local delim=""
        case "$arg" in
            #translate --gnu-long-options to -g (short options)
            --clean)                   args="${args}-c ";;
            --help)                    args="${args}-h ";;
            --cross-project)           args="${args}-p ";;
            --quickstart-only)         args="${args}-q ";;
            --service-name)            args="${args}-s ";;
            --debug)                   args="${args}-x ";;
            #pass through anything else
            *) [[ "${arg:0:1}" == "-" ]] || delim="\""
                args="${args}${delim}${arg}${delim} ";;
        esac
    done

    #Reset the positional parameters to the short options
    eval set -- $args

    while getopts "chpqs:x" OPTION
    do
         case $OPTION in
         c)
             readonly CLEAN=1
             ;;
         h)
             usage
             exit 0
             ;;
         p)
             readonly X_PROJECT=1
             ;;
         q)
             readonly QUICKSTART_ONLY=1
             ;;
         s)
             SERVICE_NAME=$OPTARG
             ;;
         x)
             readonly DEBUG='-x'
             set -x
             ;;
        esac
    done

    return 0
}

stopService() {
    local svcName=$1
    echo "--> Stop services for template '${svcName}'"

    oc delete all,secrets,sa,templates,configmaps,daemonsets,clusterroles,rolebindings,serviceaccounts --selector=template=${svcName} || true
    oc delete template ${svcName} || true
}


startService() {
    local svcName=$1
    local appName=$2
    echo "--> Start service from template '${svcName}' as '${appName}'"

    # TODO last datagrid73-dev commit on 15.11.18
    oc create -f \
        https://raw.githubusercontent.com/jboss-container-images/jboss-datagrid-7-openshift-image/f186aba68a3042605e64daac706e7ca364b1c758/services/${svcName}-template.yaml

    oc new-app ${svcName} \
        -p APPLICATION_USER=test \
        -p APPLICATION_USER_PASSWORD=changeme \
        -p APPLICATION_NAME=${appName}
}


waitForService() {
    local appName=$1
    echo "--> Wait for '${appName}'"

    ready="false"
    while [ "$ready" != "true" ];
    do
        ready=`oc get pod -l application=${appName} -o jsonpath="{.items[0].status.containerStatuses[0].ready}"`
        status=`oc get pod -l application=${appName} -o jsonpath="{.items[0].status.containerStatuses[0].state}"`
        echo "Pod: ready=${ready},status=${status}"
        sleep 10
    done
}


stopQuickstart() {
    echo "--> Stop quickstart"
    local demo=$1

    oc delete all --selector=run=${demo} || true
    oc delete imagestream quickstart || true
    oc delete buildconfig quickstart || true
}


buildQuickstart() {
    local demo=$1

    oc new-build \
        --binary \
        --strategy=source \
        --name=${demo} \
        -l app=${demo} \
        fabric8/s2i-java:2.3

    mvn -s ../../../settings.xml clean package compile -DincludeScope=runtime

    oc start-build ${demo} --from-dir=target/ --follow
}


startQuickstart() {
    local demo=$1
    local appName=$2
    local svcDnsName=$3
    echo "--> Start quickstart for ${appName} and service dns name ${svcDnsName}"

    oc run ${demo} \
        --image=`oc get is ${demo} -o jsonpath="{.status.dockerImageRepository}"` \
        --replicas=1 \
        --restart=OnFailure \
        --env APP_NAME=${appName} \
        --env SVC_DNS_NAME=${svcDnsName} \
        --env JAVA_OPTIONS=-ea
}


waitForQuickstart() {
    echo "--> Wait for quickstart"
    local demo=$1

    status=NA
    while [ "$status" != "Running" ];
    do
        status=`oc get pod -l run=${demo} -o jsonpath="{.items[0].status.phase}"`
        echo "Status of pod: ${status}"
        sleep .5
    done
}


logQuickstart() {
    echo "--> Log quickstart"
    local demo=$1

    local pod=`oc get pod -l run=${demo} -o jsonpath="{.items[0].metadata.name}"`
    oc logs ${pod} -f
}


main() {
    cmdline $ARGS

    local demo="quickstart"

    local svcName=${SERVICE_NAME}
    local appName="${svcName}-hello-world"

    local svcProject="myproject"
    local svcDnsName="${appName}-hotrod"
    local demoProject="myproject"

    if [ -n "${X_PROJECT+1}" ]; then
        svcProject="${svcName}-project"
        svcDnsName="${svcDnsName}.${svcProject}.svc.cluster.local"
        demoProject="quickstart-project"

        # oc delete project ${svcProject}
        # oc delete project ${demoProject}
        oc new-project ${svcProject} || true
        ../../registry-credentials-setup.sh
        oc new-project ${demoProject} || true
        ../../registry-credentials-setup.sh
    fi

    echo "--> Test params: service=${svcName},app=${appName}";

    if [ -n "${CLEAN+1}" ]; then
        oc project ${svcProject}
        stopService ${svcName}

        oc project ${demoProject}
        stopQuickstart ${demo}
    else
        if [ -z "${QUICKSTART_ONLY+1}" ]; then
            echo "--> Restart service";

            oc project ${svcProject}
            stopService ${svcName}
            startService ${svcName} ${appName}
            waitForService ${appName}
        fi

        echo "--> Run quickstart";

        oc project ${demoProject}
        stopQuickstart ${demo}
        buildQuickstart ${demo}
        startQuickstart ${demo} ${appName} ${svcDnsName}
        waitForQuickstart ${demo}
        logQuickstart ${demo}
    fi

}


main
