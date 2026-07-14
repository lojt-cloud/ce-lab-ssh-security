#!/bin/bash
   # Quick connection script for bootcamp instance
   
   # Colors for output
   GREEN='\033[0;32m'
   BLUE='\033[0;34m'
   NC='\033[0m' # No Color
   
   echo -e "${BLUE}Connecting to bootcamp instance...${NC}"
   ssh bootcamp-web
