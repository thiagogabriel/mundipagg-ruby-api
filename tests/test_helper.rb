require 'nori'
require 'gyoku'
class TestHelper
  def self.JoinAndConvertAmountAndCents(amount, _cents)
    amount_with_cents = amount.gsub(',', '.')
    BigDecimal.new(amount_with_cents)
  end

  def self.CreateFakePostNotification(create_order_result, manage_order_result)
    xml = '<StatusNotification xmlns="http://schemas.datacontract.org/2004/07/MundiPagg.NotificationService.DataContract"
                  xmlns:i="http://www.w3.org/2001/XMLSchema-instance">
        <AmountInCents>?</AmountInCents>
        <AmountPaidInCents>?</AmountPaidInCents>
        <BoletoTransaction i:nil="true"/>
        <CreditCardTransaction>
          <Acquirer>Cielo</Acquirer>
          <AmountInCents>?</AmountInCents>
          <AuthorizedAmountInCents>?</AuthorizedAmountInCents>
          <CapturedAmountInCents>?</CapturedAmountInCents>
          <CreditCardBrand>?</CreditCardBrand>
          <RefundedAmountInCents i:nil="true"/>
          <StatusChangedDate>?</StatusChangedDate>
          <TransactionIdentifier>?</TransactionIdentifier>
          <TransactionKey>?</TransactionKey>
          <TransactionReference>?</TransactionReference>
          <UniqueSequentialNumber>?</UniqueSequentialNumber>
          <VoidedAmountInCents i:nil="true"/>
          <PreviousCreditCardTransactionStatus>?</PreviousCreditCardTransactionStatus>
          <CreditCardTransactionStatus>?</CreditCardTransactionStatus>
        </CreditCardTransaction>
        <MerchantKey>?</MerchantKey>
        <OrderKey>?</OrderKey>
        <OrderReference>?</OrderReference>
        <OrderStatus>?</OrderStatus>
      </StatusNotification>'

    parser = Nori.new(convert_tags_to: ->(tag) { tag })
    hash = parser.parse(xml)

    credit_card_result = create_order_result[:credit_card_transaction_result_collection][:credit_card_transaction_result]
    manage_transaction_reuslt = manage_order_result[:credit_card_transaction_result_collection][:credit_card_transaction_result]

    root = hash['StatusNotification']

    root['AmountPaidInCents'] = 0
    root['CreditCardTransaction'] = {
      'Acquirer' => 'Cielo',
      'AmountInCents' => credit_card_result[:amount_in_cents],
      'AuthorizedAmountInCents' => credit_card_result[:amount_in_cents],
      'CapturedAmountInCents' => credit_card_result[:amount_in_cents],
      'CreditCardBrand' => 'Visa',
      'RefundedAmountInCents' => nil,
      'StatusChangedDate' => DateTime.now,
      'TransactionIdentifier' => Array.new(12) { [*'0'..'9', *'A'..'Z'].sample }.join,
      'TransactionKey' => credit_card_result[:transaction_key],
      'TransactionReference' => credit_card_result[:transaction_reference],
      'UniqueSequentialNumber' => Array.new(6) { [*'0'..'9'].sample }.join,
      'PreviousCreditCardTransactionStatus' => credit_card_result[:credit_card_transaction_status_enum],
      'CreditCardTransactionStatus' => manage_transaction_reuslt[:credit_card_transaction_status_enum]
    }
    root['MerchantKey'] = create_order_result[:merchant_key]
    root['OrderKey'] = create_order_result[:order_key]
    root['OrderReference'] = create_order_result[:order_reference]
    root['OrderStatus'] = manage_transaction_reuslt[:order_status_enum]

    CGI.escapeHTML(Gyoku.xml(hash))
  end
end
