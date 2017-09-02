# README #

En este repositorio se guardaran los archivos e instrucciones necesarias para el ICO de IDMoney.

### Objetivo ###

* Archivos de los Smart Contracts de IDMoney para ser instalados en Ethereum
* 1.0

### Dependencias ###

* Este ambiente esta pensado para ser bajado por Git en cualquier computadora de alquien que tenga acceso. 
* Estos archivos deben de probarse en una red test antes de ser instalados en Ethereum
* Su estructura esta pensada para ser probados con truffle (herramienta JS) pero hay otras herramientas que podrian utilizarse

## Test Automaticos ##

Para utilizar test automaticos deben de hacer lo siguiente.

* Instalar Node.js con npm
* Instalar truffle de forma global para hacer esto deben de digitar: 'npm install -g truffle' en la linea de comandos.
* Instalar testrpc que es un servidor de desarrollo de Ethereum, para esto deben de digitar los siguiente: 'npm npm install -g ethereumjs-testrpc'
* Para correr los tests se debe de correr el servidor testrpc en una ventana (testrpc) y en la otra desde el directorio principal del repositorio debe de digitarse 'truffle tests'
* Esto hace un deploy 'de mentiras' en Eth y corre tests relacionados con el token y el ICO.

## Copyright (c) 2017 IDMoney