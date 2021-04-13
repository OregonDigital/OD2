# A simple script to scrape through the Metadata Application Profile
# Leave map.csv in this directory and this script will generate a file with `property` definitions for each worktype

import csv

generic, document, image, video, audio = ([] for i in range(5))
with open('map.csv') as csvfile:
    reader = csv.reader(csvfile)
    for row in reader:
        prop = row[1]

        predicate = row[4]

        facetable = ('', ', :facetable')[row[14] == 'yes']

        searchable = str(row[16] == 'yes').lower()

        multipleExceptions = [':rights_statement', ':access_restrictions', ':repository', ':license']
        multiple = str(row[10] == '{0,n}' or row[10] == '{1,n}' or prop in multipleExceptions).lower()

        workType = row[9]

        controlledClass = row[23]
        skippedClasses = ['Hyrax Collection', 'Language', 'License', 'Types', 'RightsStatement']


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
        if workType == 'Generic':
            generic.append(md)
        elif workType == 'Document':
            document.append(md)
        elif workType == 'Image':
            image.append(md)
        elif workType == 'Video':
            video.append(md)
        elif workType == 'Audio':
            audio.append(md)

# Write out our property definitions to separate files
with open('generic', 'w') as f:
    for g in generic:
        f.write(g + "\n\n")
with open('document', 'w') as f:
    for d in document:
        f.write(d + "\n\n")
with open('image', 'w') as f:
    for i in image:
        f.write(i + "\n\n")
with open('video', 'w') as f:
    for v in video:
        f.write(v + "\n\n")
with open('audio', 'w') as f:
    for a in audio:
        f.write(a + "\n\n")
