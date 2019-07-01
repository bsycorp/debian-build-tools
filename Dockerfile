FROM golang:1.10
RUN export GOPATH=/go \
    && export PATH=$GOPATH/bin:$PATH \
    && chmod -R 777 $GOPATH \
    && APP_REPO=github.com/awslabs/amazon-ecr-credential-helper \
    && git clone https://$APP_REPO $GOPATH/src/$APP_REPO \
    && cd $GOPATH/src/$APP_REPO \
    && GOOS=linux CGO_ENABLED=0 go build -installsuffix cgo \
       -a -ldflags '-s -w' -o /usr/bin/docker-credential-ecr-login \
       ./ecr-login/cli/docker-credential-ecr-login 

FROM bitnami/minideb:stretch
COPY --from=0 /usr/bin/docker-credential-ecr-login /usr/bin/docker-credential-ecr-login
RUN install_packages curl ca-certificates bash jq wget telnet vim zip unzip \
            tree dnsutils tcpdump less groff unzip zip postgresql-client \
            libedit2 python3-pip python3-setuptools lsb-release 
RUN pip3 install awscli
COPY --from=docker:stable /usr/local/bin/docker /usr/bin/docker
# 1.11.6
COPY --from=bitnami/kubectl@sha256:92e9b698b80a298ac355c74f0bbb0318b994fcf42855fd7010f5088043b396da /opt/bitnami/kubectl/bin/kubectl /usr/bin/kubectl
# 0.11.10
COPY --from=hashicorp/terraform@sha256:3d5eb7a88d94f5216658b804acd70597e0315b8839a099a3d33baa45494bca65 /bin/terraform /usr/local/versions/0.11.10/terraform
# 0.12.2
COPY --from=hashicorp/terraform@sha256:334ecc41ba5d55cc3886cf730dec56dd5bb8d3f6d2247f3cafa54ff753d43f18 /bin/terraform /usr/local/versions/0.12.2/terraform

RUN curl -sSL https://github.com/tfutils/tfenv/releases/download/v1.0.0/tfenv-v1.0.0.zip -o /tmp/tfenv.zip && \
    echo "5d4d84d0acf04b64dfe3067fcd8e9cfc2918cba530040815ded1454ecdff617b /tmp/tfenv.zip" | sha256sum -c - && \
    unzip /tmp/tfenv.zip -d /usr/local && \
    rm -f /tmp/tfenv.zip && \
    tfenv use 0.11.10

# 1.11.0
COPY --from=aztek/kops@sha256:67fd070812756b9beb7d4f5746fd9c8e287e9c5665819ecd587afbc3c8b52a2e /usr/local/bin/kops /usr/bin/kops-1.11.0
# 1.12.2
COPY --from=aztek/kops@sha256:832b4fca5d8c548d6ec6f2a6cc3100bb236122926a2cd0d58aa8e9779d7ccd7d /usr/local/bin/kops /usr/bin/kops-1.12.2

RUN ln -s /usr/bin/kops-1.11.0 /usr/bin/kops && \
    ln -s /usr/bin/kops-1.11.0 /usr/local/bin/kops

COPY start-docker /usr/bin/start-docker
COPY codebuild-creds /usr/bin/codebuild-creds
