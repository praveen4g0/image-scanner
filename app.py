from subprocess import Popen
from flask import Flask, request, jsonify

admission_controller = Flask(__name__)

@admission_controller.route("/validate/deployments", methods=["POST"])
def deployment_webhook():
    request_info = request.get_json()
    uid = request_info["request"]["uid"]
    is_secure = True
    if 'scanner.io/owner' in request_info["request"]["object"]["metadata"]["annotations"]:
        if request_info["request"]["object"]["metadata"]["annotations"]["scanner.io/owner"]=="image-scanner":
           for each_image in request_info["request"]["object"]["spec"]["template"]["spec"]["containers"]:
                command = [
                    "/opt/app-root/src/trivy",
                    "image",
                    "-f",
                    "json",
                    "-s",
                    "CRITICAL",
                    "--exit-code",
                    "1",
                    each_image["image"],
                ]
                print("Running command: %s" % " ".join(command))
                r = Popen(command)
                r.communicate()
                if r.returncode == 1:
                    is_secure = False
        else:
         return admission_response(True, "skipping validation annotation value didn't match expected: scanner.io/owner: image-scanner", uid)            
    else:
     return admission_response(True, "skipping validation as resource doesn't have required annotation", uid)

    if is_secure:
        return admission_response(True, "All containers are secure", uid)
    return admission_response(False, "Not all containers secure, failing ...", uid)

@admission_controller.route("/validate/pods", methods=["POST"])
def pod_webhook():
    request_info = request.get_json()
    uid = request_info["request"]["uid"]
    is_secure = True
    if 'scanner.io/owner' in request_info["request"]["object"]["metadata"]["annotations"]:
        if request_info["request"]["object"]["metadata"]["annotations"]["scanner.io/owner"]=="image-scanner":
           for each_image in request_info["request"]["object"]["spec"]["containers"]:
                command = [
                    "/opt/app-root/src/trivy",
                    "image",
                    "-f",
                    "json",
                    "-s",
                    "CRITICAL",
                    "--exit-code",
                    "1",
                    each_image["image"],
                ]
                print("Running command: %s" % " ".join(command))
                r = Popen(command)
                r.communicate()
                if r.returncode == 1:
                    is_secure = False
        else:
         return admission_response(True, "skipping validation annotation value didn't match expected: scanner.io/owner: image-scanner", uid)            
    else:
     return admission_response(True, "skipping validation as resource doesn't have required annotation", uid)

    if is_secure:
        return admission_response(True, "All containers are secure", uid)
    return admission_response(False, "Not all containers secure, failing ...", uid)


def admission_response(allowed, message, uid):
    msg = {
        "apiVersion": "admission.k8s.io/v1",
        "kind": "AdmissionReview",
        "response": {"uid": uid, "allowed": allowed, "status": {"message": message}},
    }
    return jsonify(msg)

if __name__ == "__main__":
    admission_controller.run(host='0.0.0.0',
                port=5000, debug=True)