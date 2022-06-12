#! /bin/bash
#########################
## Author : Oguz BALKAYA <oguz.balkaya@gmail.com>
## Description : This script takes some parameters from the user and run the application with Docker. 
## Date : 10-06-2022
## Version : 1.0
#########################

##### Configurations

#Base directory of the script
SCRIPT=$(readlink -f "$0")
BASEDIR=$(dirname "$SCRIPT")


#Import configurations
source "$BASEDIR/run_with_docker.conf"

#####


#### usage function

usage(){
	echo -e "${USAGE}"
	exit 1
}


##### Functions to check parameter.

check_image_name(){
	#image_name parameter is required.If it is empty, show an error and finsh the script.
	if [[ -z "$image_name" ]]
	then
		echo -e "${RED}(${DATE}) [ERROR]${NC} Image name(--image-name) parameter is required." | tee -a ${STDERR_LOG_PATH}
		exit 1
	fi
}

check_image_tag(){
	#image_tag parameter is required.If it is empty, show an error and finish the script.
	if [[ -z "$image_tag" ]]
	then
		echo -e "${RED}[ERROR]${NC} Image tag(--image_tag) parameter is required." |  tee -a ${STDERR_LOG_PATH}
		exit 1
	fi
}

check_memory_limit(){
	#Memory limit parameter is not required.If parameter is not empty, use the user value.
	#If parameter is empty, use default value from configuration file.
	#If default value is 0, no limit.
	if [[ -z "$memory_limit" ]]
	then
		if [[ "$DEFAULT_MEMORY_LIMIT" != "0" ]]
		then
			$memory_limit="--memory $DEFAULT_MEMORY_LIMIT"
		fi
	else
		$memory_limit="--memory $memory_limit"
	fi
}


check_registery(){
	#Registery must be dockerhub or gitlab.
	if [[ "$registery" != "dockerhub" ]] && [[ "$registery" != "gitlab" ]]
	then
		echo -e "${RED}[ERROR}${NC} Registery parameter(--registery) must be dockerhub or gitlab." | tee -a ${STDERR_LOG_PATH}
		exit 1	
	fi	
}



check_application(){
	#If application_name parameter is empty, show an error.
	#If it is not empty, it must be mysql or mongo.	
        if [[ -z "$application_name" ]]
        then
                echo -e "${RED}[ERROR]${NC} Application name parameter(--aplication-name) is required." | tee -a ${STDERR_LOG_PATH}
                exit 1
        elif [[ "$application_name" != "mysql" ]] && [[ "$application_name" != "mongo" ]]
        then
                echo -e "${RED}[ERROR]${NC} Application name parameter(--aplication-name) must be mysql or mongo." | tee -a ${STDERR_LOG_PATH}
                exit 1
        fi
}


check_mode(){
	#Mode parameter is required.If is is empty, show an error.
	#If it is not empty, it must be build, deploy or template.
	#Check it and call functions.
        if [[ -z "$mode" ]]
        then
                echo -e "${RED}[ERROR]${NC} Mode parameter(--mode) is required." | tee -a ${STDERR_LOG_PATH}
                exit 1
        elif [[ "$mode" != "build" ]] && [[ "$mode" != "deploy" ]] && [[ "$mode" != "template" ]]
        then
                echo -e "${RED}[ERROR]${NC} MOde parameter(--mode) must be build, deploy or template." | tee -a ${STDERR_LOG_PATH}
                exit 1
        else

                if [[ "$mode" = "build" ]]
                then
                        run_build_mode
                elif [[ "$mode" = "deploy" ]]
                then
                        run_deploy_mode
                elif [[ "$mode" = "template" ]]
                then
                        run_template_app
                fi

        fi


}




#####



run_build_mode(){
	#Check image_name and image_tag parameters
        check_image_name
        check_image_tag

	#If registery parameter is not empty check registery.
        if [[ -n "$registery" ]]
        then
                check_registery
        fi

	if [[ -n "$other_parameters" ]]
	then
		DOCKER_BUILD_COMMAND+=" ${other_parameters}"
	fi
	
	#Run build command.
        DOCKER_BUILD_COMMAND+=" -t ${image_name}:${image_tag} ${DOCKERFILE_PATH}"
        eval $DOCKER_BUILD_COMMAND
	
	if [[ "$?" == "0" ]]
	then
		echo -e "${GREEN}(${DATE})[SUCCESS]${NC} Build completed. (${DOCKER_BUILD_COMMAND})" | tee -a ${STDOUT_LOG_PATH}
	else
		echo -e "${RED}(${DATE})[ERROR]${NC} An error occured when building. (${DOCKER_BUILD_COMMAND})" | tee -a ${STDERR_LOG_PATH}
	fi
}

run_deploy_mode(){
	#Check image_name and image_tag parameters.
	check_image_name
	check_image_tag

	#If container name is not empty, add it to command.
	if [[ -n "$container_name" ]]
	then
		DOCKER_RUN_COMMAND+=" --name ${container_name}"
	fi
	#If memory_limit is not empty, add it to command.
	if [[ -n "$memory_limit" ]]
	then
		DOCKER_RUN_COMMAND+=" --memory=${memory_limit}"
	else
		#If it is empty, use default limit.
		#If default limit is 0, it is unlimited.
		#If it is not 0, use default value from configuration file.
		if [[ ${DEFAULT_MEMORY_LIMIT} != "0" ]]
		then
			DOCKER_RUN_COMMAND+=" --memory=${DEFAULT_MEMORY_LIMIT}"
		fi
	fi

	#If cpu limit is not empty, add it to command.
	if [[ -n "$cpu_limit" ]]
	then
		DOCKER_RUN_COMMAND+=" --cpus=${cpu_limit}"
	else
		#If it is empty, use default limit.
		#If default limit is 0, it is unlimited.
		#If it is not 0, use default value from configuration file.
		if [[ ${DEFAULT_MEMORY_LIMIT} != "0" ]]
		then
			DOCKER_RUN_COMMAND+=" --cpus=${DEFAUL_CPU_LIMIT}"
		fi
	fi

	#If port is not empty, add it to command.
	if [[ -n "$port" ]]
	then
		DOCKER_RUN_COMMAND+=" -p ${port}"
	fi

	#If volume is not empty, add it to command.
	if [[ -n "$volume" ]]
	then
		DOCKER_RUN_COMMAND+=" -v ${volume}"
	fi

	if [[ -n "$other_parameters" ]]
	then
		DOCKER_RUN_COMMAND+=" ${other_parameters}"
	fi

	#Add image name and tag to command.
	DOCKER_RUN_COMMAND+=" ${image_name}:${image_tag}"

	#Run command.
	eval $DOCKER_RUN_COMMAND
	if [[ "$?" == "0" ]]
	then
		echo -e "${GREEN}(${DATE})[SUCCESS]${NC} Run complated. (${DOCKER_RUN_COMMAND})" | tee -a ${STDOUT_LOG_PATH}
	else
		echo -e "${RED}(${DATE})[ERROR]${NC} An error occured when running. (${DOCKER_RUN_COMMAND})" | tee -a ${STDERR_LOG_PATH}
	fi

	#If registery is not empty, check it and push the image to registery.
	if [[ -n "$registery" ]]
	then
		check_registery
		if [[ "$registery" = "dockerhub" ]]
		then
			push_to_dockerhub $image_name $image_tag
			echo -e "${GREEN}(${DATE})[SUCCESS]${NC} Pushing to DockerHub completed. (${DOCKER_RUN_COMMAND})" | tee -a ${STDOUT_LOG_PATH}
		elif [[ "$registery" = "gitlab" ]]
		then
			push_to_gitlab $image_name $image_tag
			echo -e "${GREEN}(${DATE})[SUCCESS]${NC} Pushing to GitLab Registery completed. (${DOCKER_RUN_COMMAND})" | tee -a ${STDOUT_LOG_PATH}
		fi

	fi
}

run_template_app(){
        check_application

	#If application_name is mysql, run it with docker compose
        if [[ "$application_name" = "mysql" ]]
        then
		if [[ -n "$other_parameters" ]]
		then
			DOCKERCOMPOSE_COMMAND+=" ${other_parameters}"
		fi
		DOCKERCOMPOSE_COMMAND+=" -f ${$MYSQL_COMPOSE_PATH} up"
                eval "${DOCKERCOMPOSE_COMMAND}"   
		if [[ "$?" == "0" ]]
		then
	    		echo -e "${GREEN}(${DATE})[SUCCESS]${NC} Run MySQL with Docker Compose complated. (${DOCKERCOMPOSE_COMMAND})" | tee -a ${STDOUT_LOG_PATH}	
        	else
			echo -e "${RED}(${DATE})[ERROR]${NC} An error occured when running MySQL with Docker Compose. (${DOCKER_COMPOSE_COMMAND})" | tee -a ${STDERR_LOG_PATH}
		fi
	#If it is mongo, run it with docker compose
	elif [[ "$application_name" = "mongo" ]]
        then
		if [[ -n "$other_parameters" ]]
		then
			DOCKERCOMPOSE_COMMAND+=" ${other_parameters}"
		fi
		DOCKERCOMPOSE_COMMAND+=" -f ${MONGO_COMPOSE_PATH} up"
                eval "${DOCKERCOMPOSE_COMMAND}"
		if [[ "$?" == "0" ]]
		then
			echo -e "${GREEN}(${DATE})[SUCCESS]${NC} Run Mongo with Docker Compose complated. (${DOCKERCOMPOSE_COMMAND})" | tee -a ${STDOUT_LOG_PATH}
        	else
			echo -e "${RED}(${DATE})[ERROR]${NC} An error occured when running Mongo with Docker Compose. (${DOCKER_COMPOSE_COMMAND})" | tee -a ${STDERR_LOG_PATH}
		fi
	fi

}


push_to_dockerhub(){
	#Push the image to docker hub.
	eval "${DOCKER_LOGIN_COMMAND}"
	eval "${DOCKERHUB_TAG_COMMAND} $1:$2 ${DOCKER_USERNAME}/$1:$2"
	eval "${DOCKERHUB_PUSH_COMMAND} ${DOCKER_USERNAME}/$1:$2"	
}


push_to_gitlab(){
	#Push the image to gitlab registery.
	echo "${DOCKER_LOGIN_COMMAND} registery.gitlab.com"
	echo "${DOCKER_BUILD_COMMAND} -t registery.gitlab.com/${GITLAB_USERNAME}/$1:$2 ."
	echo "${DOCKER_PUSH_COMMAND} registery.gitlab.com/${GITLAB_USERNAME}/$1:$2"
}

# run_with_docker.sh --help
if [[ "$1" = "--help" ]]
then
	usage
fi


params="$(getopt -o m:n:t:l:c:k:r:a:p:v:o: -l \
	mode:,image-name:,image-tag:,memory:,cpu:,container-name:,registery:,application-name:,port:,volume:,other: \
	--name "$0" -- "$@")"
eval set -- "$params"

while true
do
    case "$1" in
        -m|--mode)
            mode=$2
            shift 2
            ;;
        -n|--image-name)
            image_name=$2
            shift 2
            ;;
        -t|--image-tag)
            image_tag=$2
            shift 2
            ;;
	-l|--memory)
            memory_limit=$2
            shift 2
            ;;
  	-c|--cpu)
            cpu_limit=$2
            shift 2
            ;;
   	-k|--container-name)
            container_name=$2
            shift 2
            ;;
   	-r|--registery)
            registery=$2
            shift 2
            ;;
   	-a|--application-name)
            application_name=$2
            shift 2
            ;;
    	-p|--port)
	    port=$2
	    shift 2
	    ;;
        -v|--volume)
	    volume=$2
	    shift 2
	    ;;
    	-o|--other)
	    other_parameters=$2
	    shift 2
	    ;;
        --)
            shift
            break
            ;;
        *)
            echo "Not implemented: $1" >&2
            exit 1
            ;;
    esac
done

#Check mode and run the mode.
check_mode
