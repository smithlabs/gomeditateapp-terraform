package test

import (
	"crypto/tls"
	"fmt"
	"github.com/gruntwork-io/terratest/modules/http-helper"
	"github.com/gruntwork-io/terratest/modules/terraform"
	"testing"
)

func TestHelloWorldAppExample(t *testing.T) {

	t.Parallel()

	opts := &terraform.Options{
		// Run the test using the example which deploys
		// using the smithlabs/gomeditateapp:<version>
		// from DockerHub
		TerraformDir: "../examples/dockerhub",
	}

	// Clean up everything at the end of the test
	defer terraform.Destroy(t, opts)
	terraform.InitAndApply(t, opts)

	elbDnsName := terraform.OutputRequired(t, opts, "elb_dns_name")
	url := fmt.Sprintf("http://%s", elbDnsName)

	// Setup a TLS configuration to submit with the helper, a blank struct is acceptable
	tlsConfig := tls.Config{}

	http_helper.HttpGet(
		t,
		url,
		&tlsConfig,
	)
}
