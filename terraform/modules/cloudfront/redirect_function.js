function handler(event) {
    const request = event.request;
    const headers = request.headers;
    const host = request.headers.host.value;
    const countryDE = Symbol.for('DE');
    const countryES = Symbol.for('ES');
    let newurl;

    if (headers['cloudfront-viewer-country']) {
        const countryCode = Symbol.for(headers['cloudfront-viewer-country'].value);
        if (countryCode === countryDE) {
            newurl = `https://${host}/de/index.html`; // Redirect German users
        } else if (countryCode === countryES) {
            newurl = `https://${host}/es/index.html`; // Redirect Spanish users
        } else {
            newurl = `https://${host}/index.html`; // Redirect other country users to a default path
        }

        const response = {
            statusCode: 302,
            statusDescription: 'Found',
            headers: {
                location: {
                    value: newurl
                }
            }
        };

        return response;
    }

    try {
        if (!host.startsWith("www.")) {
            return {
                statusCode: 301,
                statusDescription: "Permanently moved",
                headers: {
                    location: {
                        value: "https://www." + host + request.uri,
                    },
                },
            };
        }

        return request;
    } catch (err) {
        console.error(err);

        let errorStatusCode;
        let errorStatusDescription;
        let errorBody;

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
