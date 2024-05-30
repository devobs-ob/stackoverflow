

**StackOverflow Question:** [Docker Compose: dynamically change the image architecture based on running host machine](https://stackoverflow.com/questions/78493215/docker-compose-dynamically-change-the-image-architecture-based-on-running-host)

```
quick question: is it possible to dynamically change the image's arch based on the host's machine instead of create 2 separate docker compose file?

Currently I have 2 files:

For arm64 (osx)

services:
  typesense:
    image: docker.io/typesense/typesense:0.25.2-arm64
    container_name: typesense
    restart: on-failure
    ports:
      - "8108:8108"
    volumes:
      - ./typesense-data:/data
    command: '--data-dir /data --api-key=xyz --enable-cors'
For non arm64

services:
  typesense:
    image: docker.io/typesense/typesense:0.25.2
    container_name: typesense
    restart: on-failure
    ports:
      - "8108:8108"
    volumes:
      - ./typesense-data:/data
    command: '--data-dir /data --api-key=xyz --enable-cors'
The only difference here is the image, and ideally running them e.g. docker compose up -d then let the engine decide which arch is appropriate in the host's machine instead of using docker compose -f <FILE> up -d


```

#### 1. Problem Definition

We have an interesting problem from StackOverflow. The issue is about dynamically selecting a Docker image based on the host machine's architecture. The goal is to avoid maintaining separate Docker Compose files for different architectures. One important thing to note here is the architecture is OSX, which means Apple Mac. This will be relevant when we implement our solution.
#### 2. Analysis and Decomposition

Let's break this problem down. We have two Docker Compose files that are almost identical, except for the image field, which changes based on the architecture of the host machine. Our task is to find a way to dynamically set this image without duplicating the Docker Compose files.

#### 3. Research and Exploration

To solve this problem, we need to:
- Determine the host machine's architecture.
- Use this information to dynamically set the Docker image in our Docker Compose file.

There are several ways to detect the architecture of the host machine, the easiest of which is using the `uname -m` command in a Bash script. A little Googling would reveal this to you. So, we can use this command to find the architecture of the machine, store it in a variable, and use that value to determine which image to use. Let's outline a solution.

#### 4. Solution Design

The solution involves:
1. Writing a Bash script that detects the host's architecture.
2. Setting an environment variable based on the detected architecture.
3. Modifying the Docker Compose file to use this environment variable for the image.
This might not be what this person is looking for, since it involves the use of an external script now, and I'm not sure how these Dockerfiles are called and what workflow they are a part of. In any case, for the purposes of this question, such a solution works.
#### 5. Implementation

1. **Docker Compose File**: Modify the Docker Compose file to use the environment variable.

Let's start with the easy one. We know that the image field is what is going to change based on what the arch is. 

When we think 'change', we think 'variable', since variables give us the ability to use different values for the same field. This is perfect for this scenario. We want the image value to change based on a variable.

So for now, we'll replace it with the proper syntax for variables in a Dockerfile as shown below. Everything else stays the same as the provided Dockerfile.

```yaml
version: '3.8'

services:
  typesense:
    image: ${TYPESENSE_IMAGE}
    container_name: typesense
    restart: on-failure
    ports:
      - "8108:8108"
    volumes:
      - ./typesense-data:/data
    command: '--data-dir /data --api-key=xyz --enable-cors'
```


2. **Bash Script**: Create a script named `select_image.sh`.

Next, we have to think of the logic we're trying to code here. We have a variable that will respond to the type of architecture of the OS.

- find out the OS somehow
- determine if the OS is an arm64 OSX architecture
- set the image based on the result of the above requirement

This simple bash script gets the architecture of the OS and stores it in the `ARCH` variable. Then, it compares that value with a string defined as `arm64`. This is because the question specified OSX for Apple Mac; if this was Linux, we'd be using `aarch64` instead.

If the value in `ARCH` matches `arm64`, then we use the arm image; anything else, we use the none-arm image. 

Finally, we run a `docker-compose up -d` command to bring up the container.
```bash
#!/bin/bash
ARCH=$(uname -m)
if [ "$ARCH" = "arm64" ]; then
  export TYPESENSE_IMAGE="docker.io/typesense/typesense:0.25.2-arm64"
else
  export TYPESENSE_IMAGE="docker.io/typesense/typesense:0.25.2"
fi

docker-compose up -d
```
#### 6. Testing and Validation

Run the script on an arm64 machine and a non-arm64 machine and verify that the appropriate Docker image is selected.

#### 7. Enhancement and Optimization

While our solution works, we can make some enhancements:
1. **Error Handling**: Add error handling to the script to manage unexpected scenarios.
2. **Flexibility**: Allow users to specify custom Docker image tags or repositories.

**Enhanced Script**:

```bash
#!/bin/bash

ARCH=$(uname -m)
if [ -z "$ARCH" ]; then
  echo "Error: Unable to determine architecture"
  exit 1
fi

if [ "$ARCH" = "arm64" ]; then
  export TYPESENSE_IMAGE=${TYPESENSE_IMAGE:-"docker.io/typesense/typesense:0.25.2-arm64"}
else
  export TYPESENSE_IMAGE=${TYPESENSE_IMAGE:-"docker.io/typesense/typesense:0.25.2"}
fi

docker-compose up -d
```
