// This function redirects incoming requests to the equivalent URL with "www." in the host header
function handler(event) {
    try {
        var request = event.request;
        var host = request.headers.host.value;
        var path = request.uri;

        if (!host.startsWith("www.")) {
            return {
                statusCode: 301,
                statusDescription: "Permanently moved",
                headers: {
                    location: {
                        value: "https://www." + host + path,
                    },
                },
            };
        }

        return request;
    } catch (err) {
        console.error(err);

        var errorStatusCode;
        var errorStatusDescription;
        var errorBody;

        if (err instanceof Error) {
            errorStatusCode = 500;
            errorStatusDescription = "Internal Server Error";
            errorBody = "An error occurred: " + err.message;
        } else {
            errorStatusCode = 400;
            errorStatusDescription = "Bad Request";
            errorBody = "Bad Request: " + JSON.stringify(err);
        }

        return {
            statusCode: errorStatusCode,
            statusDescription: errorStatusDescription,
            headers: {
                "content-type": {
                    value: "text/plain"
                },
            },
            body: "An error occurred: " + errorBody,
        };
    }
}
