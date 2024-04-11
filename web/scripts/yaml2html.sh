#!/bin/bash

CONFIG_MAP_FILE=${1}
TEMPLATE_FILE=${2}
OUTPUT_FILE=${3}

SKU_NAMES=$(yq '.data.skus.compute[].name' < $CONFIG_MAP_FILE)

BEGIN_TABLE_LINE=$(awk '/<!-- BEGIN TABLE BODY -->/ {print NR}' $TEMPLATE_FILE)
END_TABLE_LINE=$(awk '/<!-- END TABLE BODY -->/ {print NR}' $TEMPLATE_FILE)

echo "<tbody>" > table.tmp.html

for SKU in ${SKU_NAMES[@]}
do
  VCPU=$(yq ".data.skus.compute[] | select(.name == \"$SKU\") | .vcpu" < $CONFIG_MAP_FILE)
  RAM=$(yq ".data.skus.compute[] | select(.name == \"$SKU\") | .ram_gb" < $CONFIG_MAP_FILE)
  OS_DISK=$(yq ".data.skus.compute[] | select(.name == \"$SKU\") | .os_disk_gb" < $CONFIG_MAP_FILE)
  GPU=$(yq ".data.skus.compute[] | select(.name == \"$SKU\") | .has_gpu" < $CONFIG_MAP_FILE)

  echo "<tr>" >> table.tmp.html
  echo "  <th scope=\"row\">$SKU</th>" >> table.tmp.html
  echo "  <td>$VCPU</td>" >> table.tmp.html
  echo "  <td>$RAM</td>" >> table.tmp.html
  echo "  <td>$OS_DISK</td>" >> table.tmp.html
  echo "  <td>$GPU</td>" >> table.tmp.html
  echo "</tr>" >> table.tmp.html
done

echo "</tbody>" >> table.tmp.html

cat $TEMPLATE_FILE | head -n $BEGIN_TABLE_LINE > $OUTPUT_FILE
cat table.tmp.html >> $OUTPUT_FILE
cat $TEMPLATE_FILE | tail --lines=+$END_TABLE_LINE >> $OUTPUT_FILE

rm -f table.tmp.html
