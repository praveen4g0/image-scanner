# Using official python runtime base image
FROM registry.access.redhat.com/ubi8/python-38

# Install our requirements.txt
ADD requirements.txt app.py wsgi.py /opt/app-root/src/
RUN pip install --upgrade pip && \
    pip install -Ur requirements.txt

RUN curl -sfL https://raw.githubusercontent.com/aquasecurity/trivy/master/contrib/install.sh | sh -s -- -b /opt/app-root/src/ && \ 
    chmod +x /opt/app-root/src/trivy

CMD gunicorn --certfile=/certs/tls.crt --keyfile=/certs/tls.key --bind 0.0.0.0:443 wsgi:admission_controller
