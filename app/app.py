#!/usr/bin/env python3
"""
Простенькое веб-приложение, которое отвечает "Hello World" на любой GET-запрос 
"""

from http.server import HTTPServer, BaseHTTPRequestHandler

class HelloHandler(BaseHTTPRequestHandler):


	""" обработка GET """
	def do_GET(self):
		self.send_response(200)
		self.send_header("Content-Type", "text/plain; charset=utf-8")
		self.end_headers()
		self.wfile.write(b"Hello World!\n")


	""" Выводим логи в stdout и подхватываем systemd/journal  """
	def log_message(self, format, *args):
		print ("%s - - [%s] %s" % (self.client_address[0], self.log_date_time_string(), format % args))


""" HTTP-сервер на 0.0.0.0:8000  """
def run():
	server_address = ("0.0.0.0", 8000)
	httpd = HTTPServer(server_address, HelloHandler)
	print("Starting app on http://0.0.0.0:8000")
	httpd.serve_forever()


if __name__ == "__main__":
	run()
