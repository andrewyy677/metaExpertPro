FROM centos:8 AS builder

ARG DEBIAN_FRONTEND=noninteractive

RUN mkdir -p /metaEx/DDAraw/ /metaEx/DIAraw/ /metaEx/fasta/ /metaEx/Results/ /metaEx/sampleLabel/  /metaEx/src/00.DDAspectrallib/ /metaEx/software/fragpipe/ /opt/fragpipe20.0/
# install software
WORKDIR /metaEx/software/

RUN echo "COPY start"
COPY ./software/Miniconda3-py39_4.10.3-Linux-x86_64.sh ./
COPY ./software/diann_1.8.rpm ./
COPY ./software/fragpipe/ /metaEx/software/fragpipe/

RUN ls -la /metaEx/software/*
RUN echo "COPY end"

# Set the default command or entrypoint for the container
SHELL ["/bin/bash", "-c"]

# install miniconda3
# create CentOS-AppStream.repo file
RUN cd /etc/yum.repos.d/
RUN sed -i 's/mirrorlist/#mirrorlist/g' /etc/yum.repos.d/CentOS-*
RUN sed -i 's|#baseurl=http://mirror.centos.org|baseurl=http://vault.centos.org|g' /etc/yum.repos.d/CentOS-*

# Install dependencies
RUN yum update -y && yum install -y wget bzip2 epel-release git && yum clean all

# Download and install Conda 4.10.3
RUN wget https://repo.anaconda.com/miniconda/Miniconda3-py39_4.10.3-Linux-x86_64.sh -O miniconda.sh && \
bash miniconda.sh -b -p /opt/conda && \
rm miniconda.sh

# Add Conda to the PATH
ENV PATH="/opt/conda/bin:${PATH}"

# Update Conda and install Pip 21.1.3
RUN conda update -n base -c defaults conda && \
conda install -y pip=21.1.3

RUN pip --version

# install easyPQP
RUN pip install easypqp==0.1.35
#RUN pip install git+https://github.com/grosenberger/easypqp.git@master

RUN yum update -y && yum install -y gcc libxml2 libxml2-devel libxslt libxslt-devel perl perl-CPAN
RUN conda install -y lxml

RUN curl -L https://cpanmin.us | perl - App::cpanminus
RUN cpanm PAR::Packer

# 01.DIAquant
RUN rpm -i diann_1.8.rpm --prefix=/metaEx/software

#### 02.Annotation
SHELL ["/bin/bash", "-c"]
RUN whoami
RUN echo $HOME
#RUN cat /etc/passwd
## Unipept
# install ruby
ENV HOME /root
ENV RBENV_ROOT $HOME/.rbenv
ENV PATH $RBENV_ROOT/shims:$RBENV_ROOT/bin:$PATH

RUN yum update -y && yum install -y make openssl-devel readline-devel zlib-devel libffi-devel
 
RUN git clone https://github.com/rbenv/rbenv.git $RBENV_ROOT && \
    git clone https://github.com/rbenv/ruby-build.git $RBENV_ROOT/plugins/ruby-build && \
    echo 'export PATH="$RBENV_ROOT/bin:$PATH"' >> $HOME/.bashrc && \
    echo 'eval "$(rbenv init -)"' >> $HOME/.bashrc
ARG RUBY_VERSION=3.0.1
RUN rbenv install $RUBY_VERSION && \
    rbenv global $RUBY_VERSION
#RUN yum remove -y git gcc bzip2 openssl-devel readline-devel zlib-devel && yum clean all
RUN source $HOME/.bashrc && ruby --version
RUN yum -y --enablerepo=powertools install libyaml-devel libffi-devel

# install Unipept
RUN yum groupinstall -y 'Development Tools'
RUN gem install unipept && unipept -v
#RUN cat /root/.rbenv/versions/3.0.1/lib/ruby/gems/3.0.0/extensions/x86_64-linux/3.0.0/ffi-1.15.5/mkmf.log
## eggnog-mapper install
RUN mkdir -p /metaEx/software/eggnog-mapper/eggnog-mapper-data/ /metaEx/software/eggnog-mapper/input/ /metaEx/software/eggnog-mapper/output/

#RUN conda install -y biopython=1.78 psutil=5.7.0 xlsxwriter=1.4.3 sqlite>=3.8.2
RUN conda install -c bioconda -c conda-forge eggnog-mapper
RUN export PATH=$HOME/eggnog-mapper:$HOME/eggnog-mapper/eggnogmapper/bin:"$PATH"
RUN export EGGNOG_DATA_DIR=/metaEx/software/eggnog-mapper/eggnog-mapper-data
# RUN python create_dbs.py -m diamond
#COPY ./software/eggnog-mapper/eggnog-mapper-data/ /metaEx/software/eggnog-mapper/eggnog-mapper-data/

## install java 11.0.20
#RUN yum -y install java-11-openjdk-devel

RUN rpm -qa | grep openjdk | xargs yum -y remove
COPY ./software/jdk-11.0.20_linux-x64_bin.tar.gz /metaEx/software/
RUN tar -xvf /metaEx/software/jdk-11.0.20_linux-x64_bin.tar.gz
RUN ls /metaEx/software/
ENV JAVA_HOME /metaEx/software/jdk-11.0.20
ENV PATH $PATH:$JAVA_HOME/bin
RUN echo "export JAVA_HOME=/metaEx/software/jdk-11.0.20" >> /root/.bashrc
RUN echo "export PATH=$JAVA_HOME/bin:$PATH" >> /root/.bashrc
RUN source $HOME/.bashrc && java -version

# copy scripts
COPY ./src/00.DDAspectrallib/ /metaEx/src/00.DDAspectrallib/
COPY ./src/02.Annotation/ /metaEx/src/02.Annotation/
RUN mkdir -p /metaEx/FragPipe-jre-20.0/fragpipe/
COPY ./FragPipe-jre-20.0/fragpipe/ /metaEx/FragPipe-jre-20.0/fragpipe/
RUN chmod 777 -R /metaEx/src/
RUN ls -la /metaEx/src/
RUN chmod 777 -R /var/lib/
RUN chmod 777 -R /var/cache/
RUN chmod 777 -R /var/log/
RUN chmod 777 -R /root/
#RUN touch /.unipeptrc
#RUN chmod 777 /.unipeptrc
RUN chmod 777 -R /metaEx/
# run 00.DDAspectrallib and 01.DIAquant
WORKDIR /metaEx/src
