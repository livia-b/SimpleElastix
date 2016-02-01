#FROM debian:jessie
#
#
##modified from itk-base 
#RUN apt-get update && apt-get install -y \
#  build-essential \
#  curl \
#  cmake \
#  expect \
#  git \
#  libboost-date-time-dev \
#  libboost-dev \
#  libboost-filesystem-dev \
#  libboost-program-options-dev \
#  libboost-system-dev \
#  libboost-thread-dev \
#  libeigen3-dev \
#  libhdf5-dev \
#  libncurses-dev \
#  python-dev \
#  subversion \
#  swig \
#  vim
#  
## Normal user
#RUN useradd -m itkuser
#RUN echo 'root:itk' | chpasswd
#RUN echo 'itkuser:itk' | chpasswd
#ENV HOME /home/itkuser
#USER itkuser
#WORKDIR /home/itkuser/
#
#
## I need an expired certificate http://stackoverflow.com/a/27647891/1136458
#COPY . $HOME
#RUN  /usr/bin/expect -f $HOME/SuperBuild/acceptElastixCertificate 
#RUN mkdir -p $HOME/build/SimpleElastix
#WORKDIR /home/itkuser/build/SimpleElastix
#
#RUN  mkdir -p statismo-prefix && \ 
#    git clone -b docker_superbuild  https://github.com/livia-b/statismo.git  statismo-prefix/src && \
#    git clone https://github.com/statismo/statismo-elastix statismo-prefix/elastix 
#    
##http://simpleelastix.readthedocs.org/GettingStarted.html
##http://zarquon42b.github.io/2015/11/19/SimpleElastix/
#     
#WORKDIR $HOME/build/SimpleElastix
##let SimpleElastix superbuild take care of ITK config and dependencies
#RUN cmake $HOME/SuperBuild \
#   		-DBUILD_EXAMPLES=OFF \
#   		-DBUILD_TESTING=OFF \
#   		-DUSE_SYSTEM_SWIG=ON \
#   		-DWRAP_CSHARP=OFF \
#   		-DWRAP_JAVA=OFF \
#   		-DWRAP_LUA=OFF \
#   		-DWRAP_PYTHON=ON \
#   		-DWRAP_RUBY=OFF \
#   		-DWRAP_TCL=OFF \
#   		-DCMAKE_BUILD_TYPE=Release \
#   		-DELASTIX_USER_COMPONENT_DIRS=$HOME/build/SimpleElastix/statismo-prefix/elastix
#   		
#RUN  make -j$(grep -c processor /proc/cpuinfo) ITK
#
#RUN mkdir -p  statismo-build && \
#    cd statismo-build && \
#    cmake ../../statismo-prefix/src \
#     -DBUILD_EXAMPLES=OFF \
#     -DBUILD_TESTING=OFF \
#     -DVTK_SUPPORT=ON \
#     -DITK_DIR=$HOME/build/SimpleElastix/ITK-build \
#     -DVTK_SUPPORT=OFF 
#RUN   cd statismo-build && \  
	make  -j$(grep -c processor /proc/cpuinfo) 
   
#using sockerhub for caching
FROM liviabarazzetti/simpleelastix:StatismoConfig  


RUN make -j$(grep -c processor /proc/cpuinfo) elastix
RUN cd elastix-build && \
   cmake \
     -Dstatismo_DIR=$HOME/build/SimpleElastix/statismo-build \
     -DELASTIX_USER_COMPONENT_DIRS=$HOME/build/SimpleElastix/statismo-prefix/elastix \
     -DUSE_SimpleStatisticalDeformation=ON 
RUN make  -j$(grep -c processor /proc/cpuinfo)   elastix
#FROM liviabarazzetti/simpleelastix:ElastixConfig  
#RUN make  -j$(grep -c processor /proc/cpuinfo)      


