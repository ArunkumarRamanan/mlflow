#!/usr/bin/env bash

set -e
PROTOC_VERSION="$(protoc --version)"
if [ "$PROTOC_VERSION" != "libprotoc 3.6.0" ]; then
	echo "Must have libprotoc version 3.6.0."
	echo "We found: $PROTOC_VERSION"
	exit 1
fi
PROTOS="mlflow/protos"
protoc -I="$PROTOS" --python_out="$PROTOS" "$PROTOS"/databricks.proto \
	"$PROTOS"/service.proto \
	"$PROTOS"/scalapb/scalapb.proto

OLD_SCALAPB="from scalapb import scalapb_pb2 as scalapb_dot_scalapb__pb2"
NEW_SCALAPB="from .scalapb import scalapb_pb2 as scalapb_dot_scalapb__pb2"
sed -i'.old' -e "s/$OLD_SCALAPB/$NEW_SCALAPB/g" "$PROTOS/databricks_pb2.py" "$PROTOS/service_pb2.py"

OLD_DATABRICKS="import databricks_pb2 as databricks__pb2"
NEW_DATABRICKS="from . import databricks_pb2 as databricks__pb2"
sed -i'.old' -e "s/$OLD_DATABRICKS/$NEW_DATABRICKS/g" "$PROTOS/service_pb2.py"

rm "$PROTOS/databricks_pb2.py.old"
rm "$PROTOS/service_pb2.py.old"
