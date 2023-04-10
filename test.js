function handler(event) {
    try {
      // Extract the incoming request from the event object
      var request = event.request;
      
      // Extract the host header from the request object
      var host = request.headers.host.value;

      // Extract the path from the request object
      var path = request.uri;

      // If the host header doesn't start with "www.", redirect to the equivalent URL with "www."
      if (!host.startsWith("www.")) {
          return {
              statusCode: 301,
              statusDescription: "Permanently moved",
              headers: {
                  location: { value: "https://www." + host + path },
              },
          };
      }

      return request;
    } catch (err) {
      console.error(err);

      // If an error occurs, return an appropriate error response
      var errorStatusCode;
      var errorStatusDescription;
      var errorBody;

      // Check the type of error and set appropriate error response values
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
              "content-type": { value: "text/plain" },
          },
          body: "An error occurred: " + errorBody,
      };
    }
  }