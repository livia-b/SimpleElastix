FROM debian:jessie


#modified from itk-base 
RUN apt-get update && apt-get install -y \
  build-essential \
  curl \
  cmake \
  expect \
  git \
  libeigen3-dev \
  libncurses-dev \
  python-dev \
  subversion \
  swig \
  vim
  
# Normal user
RUN useradd -m itkuser
RUN echo 'root:itk' | chpasswd
RUN echo 'itkuser:itk' | chpasswd
ENV HOME /home/itkuser
USER itkuser
WORKDIR /home/itkuser


#http://simpleelastix.readthedocs.org/GettingStarted.html
#http://zarquon42b.github.io/2015/11/19/SimpleElastix/

RUN mkdir $HOME/src && \
    cd src && \
    git clone https://github.com/livia-b/SimpleElastix && \
    git clone  https://github.com/statismo/statismo-elastix && \
    git clone  https://github.com/statismo/statismo && \
    for PACKAGE in SimpleElastix statismo; do mkdir -p $HOME/build/$PACKAGE; done  
     
COPY SuperBuild/External_Elastix.cmake $HOME/src/SimpleElastix/SuperBuild
     
WORKDIR $HOME/build/SimpleElastix
RUN cmake $HOME/src/SimpleElastix/SuperBuild \
   		-DBUILD_EXAMPLES=OFF \
   		-DBUILD_TESTING=OFF \
   		-DUSE_SYSTEM_SWIG=ON \
   		-DWRAP_CSHARP=OFF \
   		-DWRAP_JAVA=OFF \
   		-DWRAP_LUA=OFF \
   		-DWRAP_PYTHON=ON \
   		-DWRAP_RUBY=OFF \
   		-DWRAP_TCL=OFF 
   		
COPY SuperBuild/acceptElastixCertificate $HOME
RUN  /usr/bin/expect -f $HOME/acceptElastixCertificate 
   		
RUN  make -j$(grep -c processor /proc/cpuinfo) ITK

RUN cd $HOME/build/statismo && \
    cmake $HOME/src/statismo \
        -DITK_DIR=$HOME/build/SimpleElastix/ITK-build \
        -DEIGEN3_INCLUDE_DIR:PATH=/usr/include/eigen3 \
        -DVTK_SUPPORT=OFF && \
        make -j$(grep -c processor /proc/cpuinfo) 


RUN cd $HOME/build/elastix-build && 
	cmake -DELASTIX_USER_COMPONENT_DIRS=$HOME/src/statismo-elastix
	
RUN make -j$(grep -c processor /proc/cpuinfo) 

