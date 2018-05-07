# istio-docs
The repository contains documentation covering the Istio MVP (developer preview) and associated sample applications (boosters) and tutorial scenarios (missions).

In order to make it as easy as possible to preview Istio, we've created a special version of the `oc` command line tool for OpenShift.  When you run `oc cluster up`, that single command performs the following steps:

* Creates the openshift-ansible-istio-job which runs the Ansible playbook that performs the installation.
* Starts a single-node local OpenShift cluster.
* Provisions Istio and Jaeger components on OpenShift.
* Configures automatic sidecar injection for the Istio proxy.
* Provisions a customized Fabric8 Launcher that makes example applications (boosters) available for use on OpenShift.


## Getting Started

1. You can [download the istiooc client tool  created specifically for this release from GitHub](https://github.com/openshift-istio/origin/releases).

2. Follow the [installation instructions](https://github.com/openshift-istio/istio-docs/blob/master/user-journey.adoc) to install Istio, the Fabric8 Launcher, and the Jaeger components.

3. Select a sample application (booster) and follow the README documentation for the tutorial (mission) for that Red Hat OpenShift Application Runtime.

  RHOAR missions:

 * [**Istio Circuit Breaker mission**](https://github.com/snowdrop/spring-boot-istio-circuit-breaker-booster/blob/master/README.adoc) - This scenario showcases how Istio can be used to implement the Circuit Breaker architectural pattern. 

 * [**Istio Distributed Tracing mission**](https://github.com/snowdrop/spring-boot-istio-distributed-tracing-booster/blob/master/README.adoc) - This scenario showcases the interaction of Distributed Tracing capabilities of Jaeger and properly instrumented microservices running in the Service Mesh.

 * [**Security mission**](https://github.com/snowdrop/spring-boot-istio-security-booster/blob/master/README.adoc) -This scenario showcases Istio security concepts whereby access to services is controlled by the platform rather than independently by constituent applications.

 * [**Routing mission**](https://github.com/snowdrop/spring-boot-istio-routing-booster/blob/master/README.adoc) - This scenario showcases using Istio’s dynamic traffic routing capabilities with a set of example applications designed to simulate a real-world rollout scenarios scenario.


## Communication Channels

Because this is a developer preview, we're very much hoping that you'll give us some feedback.

If you find bugs, please log an issue in GitHub against the [OpenShift-Istio project](https://github.com/openshift-istio/origin/issues).

If you want to discuss Istio, you can use our team Slack Channel = #openshift on istio.slack.com

If you want to sent more detailed questions or feedback, you can use our mailing list - istio-feedback@redhat.com.

