FROM centos:latest
MAINTAINER Jio Lee "mrjiolee@gmail.com"

RUN yum -y install wget
RUN wget http://li.nux.ro/download/nux/dextop/el7/x86_64/nux-dextop-release-0-5.el7.nux.noarch.rpm
RUN wget http://elrepo.org/linux/elrepo/el7/x86_64/RPMS/elrepo-release-7.0-2.el7.elrepo.noarch.rpm
RUN yum install -y ./nux-dextop-release-0-5.el7.nux.noarch.rpm
RUN yum install -y ./elrepo-release-7.0-2.el7.elrepo.noarch.rpm
RUN yum install -y epel-release
RUN yum install -y \
    gcc \
    gcc-c++\
    git\
    python-devel\
    protobuf-devel\
    leveldb\
    leveldb-devel\
    openblas-devel\
    snappy-devel\
    opencv-devel\
    boost-devel\
    hdf5-devel\
    gflags-devel\
    glog-devel\
    lmdb-devel\
    cuda atlas-devel\
    python2-pip\
    python2-numexpr\
    make\
    cmake\
    && yum clean all

RUN git clone https://github.com/BVLC/caffe /root/caffe

RUN cd /root/caffe && \
    pip install --upgrade pip &&\
    for req in $(cat python/requirements.txt); do pip install --no-cache-dir $req; done

RUN cd /root/caffe && \
    cp Makefile.config.example Makefile.config && \
    echo "CPU_ONLY := 1" >> Makefile.config && \
    sed -i 's/:= atlas/:= open/' Makefile.config && \
    echo "BLAS_INCLUDE := /usr/include/openblas" >> Makefile.config && \
    sed -i 's/usr\/lib\/python2.7\/dist-packages/usr\/lib64\/python2.7\/dist-packages/' Makefile.config && \
    cat Makefile.config && \
    make all && \
    make pycaffe && \
    make distribute && \
    cp -R /root/caffe/python/caffe /usr/lib64/python2.7 && \
    ln -s  /caffe/.build_release/tools/caffe /usr/bin/caffe && \
    cd /usr/lib64 && \
    ln -s /root/caffe/distribute/lib/libcaffe.so.1.0.0 && \
    ln -s /root/caffe/distribute/lib/libcaffe.so

ENV PYTHONPATH=$PYTHONPATH:/root/caffe/python

