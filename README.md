# README #

En este repositorio se guardaran los archivos e instrucciones necesarias para el ICO de IDMoney.

### Objetivo ###

* Archivos de los Smart Contracts de IDMoney para ser instalados en Ethereum
* 1.0

### Etapas del ICO ###
1. Etapa Larvae: El contrato está instalado en la red Ethereum pero no se pueden comprar tokens en forma directa. Para comprar tokens se debe hacer directamente con el founder. El founder recibe el deposito, mina los tokens y los envia a la direccion del comprador. El tipo de cambio queda a definicion del founder.
2. Etapa Pre-ICO: Se aceptan pagos directos al contrato. Tipo de Cambio: 7000x1 (7000 IDM x 1 ETH).
3. Etapa ICO: Se aceptan pagos directos al contrato. Tipo de Cambio: 10000x1 (10000 IDM x 1 ETH).
4. Post-ICO: No se aceptan pagos directos. Si se puede hacer minting si hay necesidad. También puede cerrarse la posibilidad de hacer minting desde la cuenta del fundador.

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