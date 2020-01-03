#!/usr/bin/env groovy

node('') {
    stage('Random Echo Statement') {
        echo "This is a random echo."
    }
}
