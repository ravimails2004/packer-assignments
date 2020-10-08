package main

import (
	"crypto/tls"
	"crypto/x509"
	"io/ioutil"
	"log"
	"net/http"
	"time"
)

const RootCertificatePath string = "./out/ca/CertAuth.crt"

func main() {
	var err error
	var data string
	var r *http.Request

	// create a Certificate pool to hold one or more CA certificates
	// read minica certificate and add to the Certificate Pool
	rootCAPool := x509.NewCertPool()
	rootCA, err := ioutil.ReadFile(RootCertificatePath)
	if err != nil {
		log.Fatalf("reading cert failed : %v", err)
	}
	rootCAPool.AppendCertsFromPEM(rootCA)
	log.Println("RootCA loaded")

	c := http.Client{
		Timeout: 5 * time.Second,
		Transport: &http.Transport{
			IdleConnTimeout: 10 * time.Second,
			TLSClientConfig: &tls.Config{RootCAs: rootCAPool,},
		},
	}

	if r, err = http.NewRequest(http.MethodGet, "https://ibd2.txb.gs.com:8080/server", nil); err != nil {
		log.Fatalf("request failed : %v", err)
	}

	// make the request
	if data, err = callServer(c, r); err != nil {
		log.Fatal(err)
	}
	log.Println(data)
}

func callServer(c http.Client, r *http.Request) (string, error) {
	response, err := c.Do(r)
	if err != nil {
		return "", err
	}
	defer response.Body.Close()

	data, err := ioutil.ReadAll(response.Body)
	if err != nil {
		return "", err
	}

	// print the data
	return string(data), nil
}
