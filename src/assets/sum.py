def lambda_handler(event, context):
  a = int(event['queryStringParameters']['a'])
  b = int(event['queryStringParameters']['b'])
  return {
    'statusCode': 200,
    'body': a + b
  }
