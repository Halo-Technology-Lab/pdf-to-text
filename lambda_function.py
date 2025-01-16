import io
import json
import requests
import PyPDF2

def lambda_handler(event, context):
    # Parse incoming POST request
    body = json.loads(event.get('body', '{}'))

    # Create template response
    response = {
        'statusCode': 200,
        'headers': {'Content-Type': 'application/json'},
        'body': ""
    }

    # Parse URL to process
    url = body.get('url', None)
    if url is None:
        response["statusCode"] = 400
        response["body"] = json.dumps({
            "message": "URL not provided", 
            "body": body
        })
        return response

    # Process URL and extract text
    r = requests.get(url)
    f = io.BytesIO(r.content)
    reader = PyPDF2.PdfReader(f)
    text = []
    for i in reader.pages:
        text.append(i.extract_text())
    
    # Combine text into single string
    result = "\n".join(text)

    # Send response
    response["body"] = json.dumps({
        "message": "PDF text extracted", 
        "body": result
    })
    return response
