{ manage_order_response:
  { :manage_order_result =>
    { manage_order_operation_enum: 'Capture',
      mundi_pagg_time_in_milliseconds: '122',
      order_key: 'da6ca293-ecfb-48b6-ac34-b0bdef834bdf',
      order_reference: nil,
      order_status_enum: 'PartialPaid',
      request_key: 'd9492612-a1e7-467b-9a38-6102865bac94',
      success: true,
      version: '1.0',
      credit_card_transaction_result_collection:
        { credit_card_transaction_result:
          { acquirer_message: "Transa\u00E7\u00E3o de simula\u00E7\u00E3o capturada com sucesso",
            acquirer_return_code: '0',
            amount_in_cents: '120',
            authorization_code: '217123',
            authorized_amount_in_cents: '120',
            captured_amount_in_cents: '120',
            credit_card_number: '411111****1111',
            credit_card_operation_enum: 'AuthOnly',
            credit_card_transaction_status_enum: 'Captured',
            custom_status: nil,
            due_date: nil,
            external_time_in_milliseconds: '43',
            instant_buy_key: '16b1c6d4-c72c-4bb2-a2bc-64d97fa91c91',
            refunded_amount_in_cents: nil,
            success: true,
            transaction_identifier: '329383',
            transaction_key: 'f34a0fe0-3f67-4582-a265-d03c1ac42999',
            transaction_reference: '38953gsnsad',
            unique_sequential_number: '712293',
            voided_amount_in_cents: nil,
            original_acquirer_return_collection: nil } },
            boleto_transaction_result_collection: nil,
            mundi_pagg_suggestion: nil,
            error_report: nil,
            "@xmlns:a": 'http://schemas.datacontract.org/2004/07/MundiPagg.One.Service.DataContracts',
            "@xmlns:i": 'http://www.w3.org/2001/XMLSchema-instance' },
            :@xmlns => 'http://tempuri.org/' } }
