package main

import (
	"fmt"
	"log"
	"net/http"
        "time"
)

const (
	CertPath string = "./server/ibd2.txb.gs.com.crt"
	KeyPath  string = "./server/ibd2.txb.gs.com.key"
)

func main() {
        currentTime := time.Now()
	mux := http.NewServeMux()

	// add an endpoint
	mux.HandleFunc("/server", func(w http.ResponseWriter, r *http.Request) {
		fmt.Fprint(w, "Hello from /server and current time is: ", currentTime.Format("2006-01-02 3:4:5 pm"))
	})
	log.Println("starting server")
	log.Fatal(http.ListenAndServeTLS(":8080", CertPath, KeyPath, mux))
}
