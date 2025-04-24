from azure.identity import DefaultAzureCredential
from azure.storage.blob import BlobServiceClient, BlobClient, ContainerClient

import os


client_id = os.getenv("AZURE_CLIENT_ID")
client_secret = os.getenv("AZURE_CLIENT_SECRET")
tenant_id = os.getenv("AZURE_TENANT_ID")
account_url = os.getenv("AZURE_STORAGE_ACCOUNT_URL")
container_name = os.getenv("AZURE_STORAGE_CONTAINER_NAME")
blob_name = os.getenv("AZURE_STORAGE_BLOB_NAME")

# -- Create a DefaultAzureCredential object
credential = DefaultAzureCredential(client_id=client_id, client_secret=client_secret, tenant_id=tenant_id)

def get_blob_data():
    # -- Create a BlobServiceClient object using the account URL and the credential
    blob_service_client = BlobServiceClient(account_url=account_url, credential=credential)

    # -- Get a ContainerClient object for the specified container
    container_client = blob_service_client.get_container_client(container_name)

    # -- Get a BlobClient object for the specified blob
    blob_client = container_client.get_blob_client(blob_name)

    # -- Download the blob data
    with open("downloaded_blob.txt", "wb") as download_file:
        download_file.write(blob_client.download_blob().readall())