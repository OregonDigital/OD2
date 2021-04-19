# A simple script to scrape through the Metadata Application Profile
# Leave map.csv in this directory and this script will generate a file with `property` definitions for each worktype

import csv

generic, document, image, video, audio = ({'metadata': [], 'form': []} for i in range(5))

with open('map.csv') as csvfile:
    reader = csv.reader(csvfile)
    for row in reader:
        prop = row[1]

        predicate = row[4]

        model = row[8]
        formVisible = row[19].lower() == 'yes'

        facetable = ('', ', :facetable')[row[14] == 'yes']

        searchable = str(row[16] == 'yes').lower()

        multipleExceptions = [':rights_statement', ':access_restrictions', ':repository', ':license']
        multiple = str(row[10] == '{0,n}' or row[10] == '{1,n}' or prop in multipleExceptions).lower()

        workType = row[9]

        controlledClass = row[23]
        skippedClasses = ['Hyrax Collection', 'Language', 'License', 'Types', 'RightsStatement']

        # Skip this property if it's not meant to be on a Work
        if 'work' not in model.lower():
            continue
        # skip this property if prop or predicate isn't in MAP
        if len(prop) == 0 or len(predicate) <= 1:
            continue

        # Craft our property statements in this format:
        # property :prop_name, predicate: RDF::Vocab::Vocabulary.predicate, multiple: true/false, class_name: OregonDigtal::ControlledVocabularies::Vocab do |index|
        #   index.as :stored_searchable, :facetable
        # end
        md = "property %s, predicate: %s, multiple: %s, basic_searchable: %s"%(prop, predicate, multiple, searchable)

        # Add optional class_name if this is a controlled vocab
        if controlledClass in skippedClasses:
          pass
        elif controlledClass == 'Location':
            md += ", class_name: Hyrax::ControlledVocabularies::%s"%(controlledClass)
        elif not controlledClass == 'N/A':
            md += ", class_name: OregonDigital::ControlledVocabularies::%s"%(controlledClass)

        # Add indexing information
        md += " do |index|"
        md += "\n  index.as :stored_searchable%s"%(facetable)
        md += "\nend"

        # Gather all these definitions up to write them out later
        toWriteTo = generic
        if workType == 'Document':
            toWriteTo = document
        elif workType == 'Image':
            toWriteTo = image
        elif workType == 'Video':
            toWriteTo = video
        elif workType == 'Audio':
            toWriteTo = audio
        toWriteTo['metadata'].append(md)
        if formVisible:
            if workType == 'Generic':
                generic['form'].append(prop)
                document['form'].append(prop)
                image['form'].append(prop)
                video['form'].append(prop)
                audio['form'].append(prop)
            else:
                toWriteTo['form'].append(prop)

# Write out our property definitions to separate files
with open('generic_metadata', 'w') as f:
    for g in generic['metadata']:
        f.write(g + "\n\n")
with open('generic_form', 'w') as f:
    f.write("ORDERED_TERMS = %i[\n")
    for g in generic['form']:
        f.write("  " + g[1:] + "\n")
    f.write("].freeze")
with open('document_metadata', 'w') as f:
    for d in document['metadata']:
        f.write(d + "\n\n")
with open('document_form', 'w') as f:
    f.write("ORDERED_TERMS = %i[\n")
    for d in document['form']:
        f.write("  " + d[1:] + "\n")
    f.write("].freeze")
with open('image_metadata', 'w') as f:
    for i in image['metadata']:
        f.write(i + "\n\n")
with open('image_form', 'w') as f:
    f.write("ORDERED_TERMS = %i[\n")
    for i in image['form']:
        f.write("  " + i[1:] + "\n")
    f.write("].freeze")
with open('video_metadata', 'w') as f:
    for v in video['metadata']:
        f.write(v + "\n\n")
with open('video_form', 'w') as f:
    f.write("ORDERED_TERMS = %i[\n")
    for v in video['form']:
        f.write("  " + v[1:] + "\n")
    f.write("].freeze")
with open('audio_metadata', 'w') as f:
    for a in audio['metadata']:
        f.write(a + "\n\n")
with open('audio_form', 'w') as f:
    f.write("ORDERED_TERMS = %i[\n")
    for a in audio['form']:
        f.write("  " + a[1:] + "\n")
    f.write("].freeze")
