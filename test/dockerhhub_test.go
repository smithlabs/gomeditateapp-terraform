package test

import (
	"fmt"
	"github.com/gruntwork-io/terratest/modules/http-helper"
	"github.com/gruntwork-io/terratest/modules/terraform"
	"testing"
	"time"
	"crypto/tls"
)

func TestHelloWorldAppExample(t *testing.T)  {

	t.Parallel()

	opts := &terraform.Options{
		// Run the test using the DockerHub example
		TerraformDir: "../examples/dockerhub",
	}

	// Clean up everything at the end of the test
	defer terraform.Destroy(t, opts)
	terraform.InitAndApply(t, opts)

	elbDnsName := terraform.OutputRequired(t, opts, "elb_dns_name")
	url := fmt.Sprintf("http://%s/health", elbDnsName)

	expectedStatus := 200
	expectedBody := "Online!"

	maxRetries := 20
	timeBetweenRetries := 10 * time.Second

	// Setup a TLS configuration to submit with the helper, a blank struct is acceptable
	tlsConfig := tls.Config{}

	http_helper.HttpGetWithRetry(
		t,
		url,
		&tlsConfig,
		expectedStatus,
		expectedBody,
		maxRetries,
		timeBetweenRetries,
	)

}
