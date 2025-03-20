import logging
import azure.functions as func

def main(req: func.HttpRequest) -> func.HttpResponse:
    logging.info('Azure Function triggered via HTTP request.')

    name = req.params.get('name')
    if not name:
        try:
            req_body = req.get_json()
        except ValueError:
            return func.HttpResponse("Invalid request body", status_code=400)
        else:
            name = req_body.get('name')

    if name:
        return func.HttpResponse(f"Hello, {name}!")
    else:
        return func.HttpResponse(
            "Please pass a name in the query string or in the request body",
            status_code=400
        )

if __name__ == "__main__":
    from azure.functions import HttpRequest
    import json

    # Simulate an HTTP request
    req = HttpRequest(
        method="GET",
        url="/api/hello",
        body=None,
        headers={},
        params={"name": "World"}
    )

    # Call the main function and print the response
    response = main(req)
    print(response.get_body().decode())
