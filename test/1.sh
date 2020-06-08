#!/bin/sh

#name_list="calendar et_emailer audit_log fxreference draftprocessing wallet reco ledger et_awx_ocs_ebay et_awx_ocs et_awx_ocs_amazon fee_engine airboard_ng_api batchpayments authorisation compliance"

name_list="et_emailer authorisation draftprocessing calendar audit_log et_awx_ocs_ebay fxreference wallet reco airboard_ng_api et_awx_ocs_amazon et_awx_ocs batchpayments compliance"

for name in ${name_list}
do
	echo $name
done
