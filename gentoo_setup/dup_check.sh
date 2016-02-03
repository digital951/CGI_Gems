
echo "Range = 128.206.116.193 - 128.206.116.254"

SUBNET=128.206.116
for n in {193..254}; do
  ADDR=${SUBNET}.${n}
  echo -e "${ADDR}\t$(arping -D -I eth2 ${ADDR})"
done

