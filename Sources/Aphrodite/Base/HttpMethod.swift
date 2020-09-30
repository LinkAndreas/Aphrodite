//  Copyright © 2020 Andreas Link. All rights reserved.

/// The method to be used for the Http Request. Reference: https://www.tutorialspoint.com/http/http_methods.htm
public enum HttpMethod: String {
    /// Establishes a tunnel to the server identified by a given URI.
    case connect = "CONNECT"
    /// Removes all current representations of the target resource given by a URI.
    case delete = "DELETE"
    /// The GET method is used to retrieve information from the given server using a given URI.
    case get = "GET"
    /// Same as GET, but transfers the status line and header section only.
    case head = "HEAD"
    /// Describes the communication options for the target resource.
    case options = "OPTIONS"
    /// The Http PATCH request method applies partial modifications to a resource.
    case patch = "PATCH"
    /// A POST request is used to send data to the server, for example, customer information, file upload, etc. using HTML forms.
    case post = "POST"
    /// Replaces all current representations of the target resource with the uploaded content.
    case put = "PUT"
    /// Performs a message loop-back test along the path to the target resource.
    case trace = "TRACE"
}
