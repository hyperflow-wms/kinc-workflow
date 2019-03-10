FROM fedora:25

RUN dnf -y update

RUN dnf -y install \
	lapack \
	gcc-gfortran \
	libstdc++ \
	openblas \
	vim \
	wget \
	findutils
	
WORKDIR /home

ADD tools/kinc-wrapper-docker /bin/kinc-wrapper
ADD task-files/kinc /bin/kinc
#ADD workflow.json /
ADD http://www.mixmod.org/IMG/rpm/libmixmod_3.2.2-runtime.rpm /

RUN dnf -y install /libmixmod_3.2.2-runtime.rpm

ADD http://download-ib01.fedoraproject.org/pub/fedora/linux/releases/29/Everything/x86_64/os/Packages/g/gsl-2.4-7.fc29.x86_64.rpm /
RUN dnf -y install /gsl-2.4-7.fc29.x86_64.rpm

#CMD ["/home/kinc-wrapper","Yeast-GEM.tar.gz","Yeast-GEM.txt","1","100000","188","7051"]
