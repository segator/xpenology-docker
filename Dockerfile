FROM segator/qemu-kvm

ENV DISK_SIZE 101G
ENV VM_IP 20.20.20.21
ENV THREADS 2
ENV CORES 2
ENV MEMORY 2048
ENV HDD_CACHE none

COPY synoboot.img /synoboot.img
COPY bin /usr/bin/
RUN chmod -R +x /usr/bin \
    && mkdir /image

EXPOSE 5000
EXPOSE 5001
EXPOSE 139
EXPOSE 445
EXPOSE 111
EXPOSE 892
EXPOSE 2049

ENTRYPOINT /usr/bin/startvm
