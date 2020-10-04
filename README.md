# Json Version Bumper

This is a simple webapp which will update a json file on disk with a newer version

example file:

```json
{
  "myApp": "1.2.3"
}
```

## Configuration

### Environment Variables

This app uses the following environments variables:

| Name | Required | Description |
| ---| --- | ---|
| GITHUB_TOKEN| Yes| Token to access the github api, this will be used to write the status to the pr |
| TARGET_REPO| Yes | The repository to find the file in `JSON_FILE_PATH` in
| JSON_FILE_PATH| Yes | The path from the repo root to find the file in
| SECRET_TOKEN | No| If supplied it will do a HMAC check against the incomming request |

### Webhook

To configure the webhook you will want to do the following:

URL: <https://example.com/handler>
Events:
  Let me select:
    Releases (Only)

If you set a HMAC secret ensure that `SECRET_TOKEN` is set to the same secret value

## Docker images

Docker images are supplied under Xorima on docker hub, <https://hub.docker.com/r/xorima/json_version_bumper/>
