#! /usr/bin/python3
import argparse
import json
import os
import re
from pprint import pprint
import urllib.request
from datetime import datetime

### WARNING ###
# This script is somewhat brittle
# Only pass in exactly URIs for --uris
# Only pass a file of uris separated by line breaks to --file

start_time = datetime.now()

FEDORA_BASE_URL = os.environ.get('FEDORA_URL')
FEDORA_ENV = ('dev', 'prod')[os.environ.get('RAILS_ENV') == 'production']
FEDORA_ENV_URL = f'{FEDORA_BASE_URL}/{FEDORA_ENV}'
CONTAINS_PREDICATE = 'http://www.w3.org/ns/ldp#contains'
URI_KEY = '@id'

# Take in an array of URIs or default to the Fedora base URI
parser = argparse.ArgumentParser(description='Crawl a fedora base url')
parser.add_argument('-F', '--files', default=[], nargs='+',
                    help='List of files that contain root URIs to start the crawler with')
parser.add_argument('-U', '--uris', default=[FEDORA_ENV_URL], nargs='+',
                    help='List of root URIs to start the crawler with')
parser.add_argument('-s', '--skip_base', action='store_true',
                    help='Skip the base URI of the graph. This will also skip URIs given by -F/--files')

args = parser.parse_args()

# We're going to push (append) and pop uris from uri_stack. Use base/--uris list unless --skip_base
uri_stack = (args.uris, [])[args.skip_base]
# Import from --files
for file in args.files:
    uri_stack += [line.strip() for line in open(file, "r")]

# And we're going to store all uris in final_uri list. This actually might be a bad idea for memory
#   maybe we should just log each uri then throw it away
final_uri = []
print('Starting URI stack:')
pprint(uri_stack)

# This is pretty cool. While uri_stack has values we'll loop, and since we're going to push and pop to uri_stack we'll iterate all uris
while uri_stack:
    print("\n")
    # get the uri from the top of the stack
    uri = uri_stack.pop()
    # Print the working URI
    print(uri)

    # Setup for the request to fedora
    req = urllib.request.Request(uri)
    req.add_header('Accept', 'application/ld+json')
    try:
        response = urllib.request.urlopen(req)
    except:
        uri_stack = [uri] + uri_stack
        continue
    # Read the response into JSON
    data = response.read()
    encoding = response.info().get_content_charset('utf-8')
    json_response = json.loads(data.decode(encoding))

    # Add to the final_uri list
    final_uri.append(uri)
    # Leaf nodes won't contain the contains predicate
    if not CONTAINS_PREDICATE in json_response[0]:
        continue

    # For each URI this node contains we'll push it onto the stack
    for contained in json_response[0][CONTAINS_PREDICATE]:
        # Except we'll skip it if the uri points to a binary
        if re.search("/files/.{36}$", contained[URI_KEY]):
            continue
        uri_stack.append(contained[URI_KEY])

end_time = datetime.now()

# Debug print statements
# print('uri_stack:')
# pprint(uri_stack)
# print("\n")
# print('final_uri')
# pprint(final_uri)
# print("\n")

# Print times
print("Start time:", start_time)
print("End time:", end_time)
print("Total time:", end_time - start_time)

# Write file out to 'out_YYYYmmddTHHMMSS.ffffff.txt'
end_time_stamp = end_time.strftime("%Y%m%dT%H%M%S.%f")
with open(f'out_{end_time_stamp}.txt', "w") as file:
    file.write(f'Start time: {start_time}\n')
    file.write(f'End time: {end_time}\n')
    file.write(f'total_time: {end_time - start_time}\n')
    print(*final_uri, sep='\n', file=file)
