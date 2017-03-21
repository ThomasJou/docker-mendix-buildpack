# Dockerfile to create a Mendix Docker image based on either the source code or
# Mendix Deployment Archive (aka mda file)
#
# Author: Mendix Digital Ecosystems, digitalecosystems@mendix.com
# Version: 1.5

FROM cloudfoundry/cflinuxfs2
MAINTAINER Mendix Digital Ecosystems <digitalecosystems@mendix.com>

# Build-time variables
ARG BUILD_PATH

# Create Mendix user
RUN useradd -ms /bin/bash mendix

# Log in with Mendix user
WORKDIR /home/mendix

# Checkout CF Build-pack here
RUN mkdir -p buildpack/.local && \
  (wget -qO- https://github.com/mendix/cf-mendix-buildpack/archive/more_robust_license_file_path.tar.gz \
  | tar xvz -C buildpack --strip-components 1)



# Copy python scripts which execute the buildpack (exporting the VCAP variables)
COPY scripts buildpack/

# Add the buildpack modules
ENV PYTHONPATH "/home/mendix/buildpack/lib/"

# Create the build destination
RUN mkdir build cache
COPY $BUILD_PATH build/

# Compile the application source code
# WORKDIR /home/mendix/buildpack
RUN ["/home/mendix/buildpack/compilation", "/home/mendix/build", "/home/mendix/cache"]

# Expose nginx port
ENV PORT 80
EXPOSE $PORT

# Change owner of build folder
RUN chown -R mendix /home/mendix/build

# Login as mendix
USER mendix

# Start up application
COPY scripts /home/mendix/build/
WORKDIR /home/mendix/build

ENTRYPOINT ["/home/mendix/build/startup","/home/mendix/build/start.py"]
