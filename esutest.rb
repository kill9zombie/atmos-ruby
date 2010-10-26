require 'test/unit'
require 'tempfile'
require 'EsuApi'
require 'uri'

class Esutest < Test::Unit::TestCase
  def initialize( id )
    super(id)
    @esu = EsuApi::EsuRestApi.new( "192.168.15.115",80,"connectic","D7qsp4j16PBHWSiUbc/bt3lbPBY=")
  end

  def setup
    @cleanup = []
    @cleanfiles = []
  end

  def teardown
    @cleanup.each { |id| @esu.delete_object( id ) }
    @cleanfiles.each { |file| file.close! }
  end

  # 
  # Test creating one empty object.  No metadata, no content.
  # 
  def test_create_empty_object()
    id =  @esu.create_object( nil, nil, nil, nil )
    assert_not_nil( id, "nil ID returned" );
    @cleanup.push( id )

    # Read back the content
    content = @esu.read_object( id, nil, nil )
    assert_equal( "", content, "object content wrong" );
  end
  
  def test_hmac
    str = "Hello World"
    value = HMAC::SHA1.digest( Base64.decode64( "D7qsp4j16PBHWSiUbc/bt3lbPBY=" ), str )
    signature = Base64.encode64( value ).chomp()
    print "String to sign: #{str}\nSignature: #{signature}\nValue: #{value}\n"
    assert_equal( "kFcjtduMr0rljJHxJRqF8i1DNp4=", signature, "HMAC failed to validate" )
  end

#  def test_create_empty_object_on_path()
#    op = EsuApi::ObjectPath.new( '/' + randomstr( 8 ) )
#    id = @esu.create_object_on_path( op, nil, nil, nil, nil )
#    assert_not_nil( id, "nil ID returned" );
#    @cleanup.push( id )
#
#    # Read back the content
#    content = @esu.read_object( id, nil, nil )
#    assert_equal( "", content, "object content wrong" );
#  end
#
  def test_create_object_with_content()
    id =  @esu.create_object( nil, nil, "hello", "text/plain" )
    assert_not_nil( id, "nil ID returned" );
    @cleanup.push( id )

    # Read back the content
    content = @esu.read_object( id, nil, nil )
    assert_equal( "hello", content, "object content wrong" );
  end
  
  def test_update_object
    id =  @esu.create_object( nil, nil, "hello", "text/plain" )
    assert_not_nil( id, "nil ID returned" );
    @cleanup.push( id )
    
    # Change the content
    @esu.update_object( id, nil, nil, "Hello World", "text/plain" )

    # Read back the content
    content = @esu.read_object( id, nil, nil )
    assert_equal( "Hello World", content, "object content wrong" );
    
  end
  
#
#  def test_create_object_with_stream()
#    stream = createTestStream( 40 )
#    id = @esu.create_object( nil, nil, stream.open, "text/plain" )
#
#    @cleanup.push( id )
#
#    # Read back the content
#    content = @esu.read_object( id, nil, nil )
#    assert_equal( content, stream.open.readlines, "object content wrong" );
#  end
#
#  def test_create_object_with_metadata()
#    meta = {}
#    meta['listable'] = EsuApi::Metadata.new( "listable", "foo", true )
#    meta['unlistable'] = EsuApi::Metadata.new( "unlistable", "bar", false )
#    meta['listable2'] = EsuApi::Metadata.new( "listable2", "foo2   foo2", true )
#    meta['unlistable2'] = EsuApi::Metadata.new( "unlistable2", "bar2    bar2", false )
#    id = @esu.create_object( nil, meta, nil, nil )
#    @cleanup.push( id )
#
#    # Read back and check
#    meta = @esu.get_user_metadata( id )
#
#    assert_equal( "foo", meta["listable"].value, "Value of listable wrong" )
#    assert_equal( "bar", meta["unlistable"].value, "Value of unlistable wrong" )
#    assert_equal( "foo2   foo2", meta["listable2"].value, "Value of listable2 wrong" )
#    assert_equal( "bar2    bar2", meta["unlistable2"].value, "Value of unlistable2 wrong" )
#  end
#  
#  def test_acl
#    acl = createAcl
#    id = @esu.create_object( acl, nil, nil, nil )
#    @cleanup.push( id )
#    
#    # Read back and check
#    newacl = @esu.getAcl( id )
#    check_acl( acl, newacl )
#  end
#  
#  def test_acl_on_path
#    acl = createAcl
#    op = EsuApi::ObjectPath.new( '/' + randomstr( 8 ) )
#    id = @esu.create_object_on_path( op, acl, nil, nil, nil )
#    @cleanup.push( id )
#    
#    # Read back and check
#    newacl = @esu.get_acl( id )
#    check_acl( acl, newacl )
#  end
#  
#  def test_delete_user_metadata
#    meta = {}
#    meta['listable'] = EsuApi::Metadata.new( "listable", "foo", true )
#    meta['unlistable'] = EsuApi::Metadata.new( "unlistable", "bar", false )
#    meta['listable2'] = EsuApi::Metadata.new( "listable2", "foo2   foo2", true )
#    meta['unlistable2'] = EsuApi::Metadata.new( "unlistable2", "bar2    bar2", false )
#    id = @esu.create_object( nil, meta, nil, nil )
#    @cleanup.push( id )
#    
#    # Delete some metadata
#    deleteList = [ 'listable', 'unlistable' ]
#    @esu.delete_user_metadata( id, deleteList )
#      
#    # Read back and check
#    meta = @esu.get_user_metadata( id )
#
#    assert_nil( meta["listable"], "listable should have been deleted" )
#    assert_nil( meta["unlistable"], "unlistable should have been deleted" )
#    assert_equal( "foo2   foo2", meta["listable2"].value, "Value of listable2 wrong" )
#    assert_equal( "bar2    bar2", meta["unlistable2"].value, "Value of unlistable2 wrong" )
#  end
#  
#  def test_delete_version
#    id = @esu.create_object( nil, nil, nil, nil )
#    @cleanup.push( id )
#    
#    # Create some versions
#    vid1 = @esu.version_object( id );
#    vid2 = @esu.version_object( id );
#    
#    # Delete one of the versions
#    @esu.delete_version( vid1 )
#    
#    # List back the versions
#    vlist = @esu.listVersions( id );
#    assert_equal( 1, vlist.size, "Only expected one version" )
#    assert_equal( vid2, vlist[0], "Expected second vid" )
#  end
#  
#  def test_restore_version
#    id = @esu.create_object( nil, nil, "Original Content", "text/plain" )
#    @cleanup.push( id )
#    
#    # Version the object
#    vid1 = @esu.version_object( id )
#    
#    # Change the content
#    @esu.update_object( id, nil, nil, "New content you should never see", "text/plain" )
#    
#    # restore the first version
#    @esu.restore_version( id, vid1 )
#    
#    # Read back the content
#    content = @esu.read_object( id )
#    assert_equal( "Original Content", content, "Expected original content" )
#  end
#  
#  def test_get_system_metadata
#    id = @esu.create_object( nil, nil, "12345", "text/plain" )
#    @cleanup.push( id )
#    
#    tags = [ 'ctime', 'size' ]
#    smeta = @esu.get_system_metadata( id, tags )
#    
#    assert_not_nil( smeta['ctime'], "Expected ctime to be set" )
#    assert_equal( 5, smeta['size'].value, "Expected object size to be five" )
#  end
#  
#  def test_list_objects
#    meta = {}
#    meta['listable'] = EsuApi::Metadata.new( "listable", "foo", true )
#    meta['unlistable'] = EsuApi::Metadata.new( "unlistable", "bar", false )
#    meta['listable2'] = EsuApi::Metadata.new( "list/able/2", "foo2   foo2", true )
#    meta['unlistable2'] = EsuApi::Metadata.new( "un/list/able2", "bar2    bar2", false )
#    id = @esu.create_object( nil, meta, nil, nil )
#    @cleanup.push( id )
#    
#    # List tags and check membership
#    objects = @esu.list_objects( "listable" );
#    assert_true( objects.include?(id), "Expected object to be listable" );
#    
#    objects = @esu.list_objects( "unlistable" )
#    assert_true( !objects.include?(id), "Expected object to not be unlistable" )
#    
#    objects = @esu.list_objects( "list/able/2" )
#    assert_true( objects.include?(id), "Expected object to be listable" )
#  end
#  
#  def test_list_objects_with_metadata
#    meta = {}
#    meta['listable'] = EsuApi::Metadata.new( "listable", "foo", true )
#    meta['unlistable'] = EsuApi::Metadata.new( "unlistable", "bar", false )
#    meta['listable2'] = EsuApi::Metadata.new( "list/able/2", "foo2   foo2", true )
#    meta['unlistable2'] = EsuApi::Metadata.new( "un/list/able2", "bar2    bar2", false )
#    id = @esu.create_object( nil, meta, nil, nil )
#    @cleanup.push( id )
#    
#    # List tags and check membership
#    objects = @esu.list_objects_with_metadata( "listable" );
#    assert_true( objects.include?(id), "Expected object to be listable" );
#    
#    oid = objects[ objects.index(id) ]
#    
#    # Check metadata
#    assert_equal( "foo", oid.meta['listable'], "Expected metadata to be set on object" )
#  end
#  
#  def test_get_listable_tags
#    meta = {}
#    meta['listable'] = EsuApi::Metadata.new( "listable", "foo", true )
#    meta['unlistable'] = EsuApi::Metadata.new( "unlistable", "bar", false )
#    meta['listable2'] = EsuApi::Metadata.new( "list/able/2", "foo2   foo2", true )
#    meta['unlistable2'] = EsuApi::Metadata.new( "list/able/not", "bar2    bar2", false )
#    id = @esu.create_object( nil, meta, nil, nil )
#    @cleanup.push( id )
#    
#    # Check root tags
#    tags = @esu.get_listable_tags( nil )
#    assert( tags.include?('listable'), "Expected listable in root" )
#    assert( tags.include?('list'), "Expected list in root" )
#    assert( !tags.include?('unlistable'), "Expected unlistable to be missing" )
#    
#    # Check deeper tag
#    tags = @esu.get_listable_tags( 'list/able' )
#    assert( tags.include?( '2' ), "Expected child tag" )
#    assert( !tags.include?( 'listable' ), "Root tag found in child" )
#    assert( !tags.include?( 'not' ), "Found unlistable tag" )
#  end
#  
#  def test_list_user_metadata_tags
#    meta = {}
#    meta['listable'] = EsuApi::Metadata.new( "listable", "foo", true )
#    meta['unlistable'] = EsuApi::Metadata.new( "unlistable", "bar", false )
#    meta['listable2'] = EsuApi::Metadata.new( "list/able/2", "foo2   foo2", true )
#    meta['unlistable2'] = EsuApi::Metadata.new( "list/able/not", "bar2    bar2", false )
#    id = @esu.create_object( nil, meta, nil, nil )
#    @cleanup.push( id )
#
#    # Check tags
#    tags = @esu.list_user_metadata_tags( id )
#    assert( tags.include?('listable'), "Metadata listable tag missing" );    
#    assert( tags.include?('unlistable'), "Metadata unlistable tag missing" );    
#    assert( tags.include?('list/able/2'), "Metadata list/able/2 tag missing" );    
#    assert( tags.include?('list/able/not'), "Metadata list/able/not tag missing" );    
#  end
#  
#  def test_update_object
#    meta = {}
#    meta['listable'] = EsuApi::Metadata.new( "listable", "foo", true )
#    meta['unlistable'] = EsuApi::Metadata.new( "unlistable", "bar", false )
#    id = @esu.create_object( nil, meta, "Four score and seven years ago", "text/plain" )
#    @cleanup.push( id )
#    
#    # Update object
#    meta = {}
#    meta['listable'] = EsuApi::Metadata.new( "listable", "xxx", true )
#    meta['unlistable'] = EsuApi::Metadata.new( "unlistable", "yyy", false )
#    @esu.update_object( nil, meta, "New content here", "text/plain" )
#
#    # Read back metadata and check
#    meta = @esu.get_user_metadata( id )
#
#    assert_equal( "xxx", meta["listable"].value, "Value of listable wrong" )
#    assert_equal( "yyy", meta["unlistable"].value, "Value of unlistable wrong" )
#    
#    # Read back the content
#    content = @esu.read_object( id, nil, nil )
#    assert_equal( "New content here", content, "object content wrong" );
#  end
#  
#  def test_update_object_with_stream()
#    stream = createTestStream( 40 )
#    id = @esu.create_object( nil, nil, stream.open, "text/plain" )
#  
#    @cleanup.push( id )
#    
#    stream2 = createTestStream( 45 )
#    @esu.update_object( nil, nil, stream2.open(), "text/plain" )
#  
#    # Read back the content
#    content = @esu.read_object( id, nil, nil )
#    assert_equal( content, stream2.open.readlines, "object content wrong" );
#  end
#  
#  def test_list_directory()
#    dir = '/' + randomstr( 8 )
#    
#    file1 = EsuApi::ObjectPath.new( dir + '/' + randomstr( 8 ) )
#    file2 = EsuApi::ObjectPath.new( dir + '/' + randomstr( 8 ) )
#    dir2 = EsuApi::ObjectPath.new( dir + '/' + randomstr( 8 ) + '/' )
#    id1 = @esu.create_object_on_path( file1, nil, nil, nil, nil )
#    @cleanup.push( id1 )
#    id2 = @esu.create_object_on_path( file2, nil, nil, nil, nil )
#    @cleanup.push( id2 )
#    id3 = @esu.create_object_on_path( dir2, nil, nil, nil, nil )
#    @cleanup.push( id3 )
#    
#    dirlist = @esu.list_directory( EsuApi::ObjectPath.new( dir + '/' ) )
#    assert( dirlist.find { |entry| entry == file1 }, "could not locate " + file1 )
#    assert( dirlist.find { |entry| entry == file2 }, "could not locate " + file2 )
#    assert( dirlist.find { |entry| entry == dir2 }, "could not locate " + dir2 )
#  end
# 
#  def test_get_all_metadata()
#    meta = {}
#    meta['listable'] = EsuApi::Metadata.new( "listable", "foo", true )
#    meta['unlistable'] = EsuApi::Metadata.new( "unlistable", "bar", false )
#    meta['listable2'] = EsuApi::Metadata.new( "listable2", "foo2   foo2", true )
#    meta['unlistable2'] = EsuApi::Metadata.new( "unlistable2", "bar2    bar2", false )
#    acl = createAcl
#    op = EsuApi::ObjectPath.new( '/' + randomstr( 8 ) )
#    id = @esu.create_object_on_path( op, acl, meta, "object content", "text/plain" )
#    
#    om = @esu.get_object_metadata( op )
#
#    check_acl( acl, om.acl )    
#    assert_equal( "text/plain", om.mimetype, "wrong mimetype" )
#    assert_equal( "foo", om.meta["listable"].value, "Value of listable wrong" )
#    assert_equal( "bar", om.meta["unlistable"].value, "Value of unlistable wrong" )
#    assert_equal( "foo2   foo2", om.meta["listable2"].value, "Value of listable2 wrong" )
#    assert_equal( "bar2    bar2", om.meta["unlistable2"].value, "Value of unlistable2 wrong" )
#  end
#  
#  def test_get_shareable_url()
#    text = "The quick brown fox jumped over the lazy dog"
#    id = @esu.create_object( nil, nil, text, 'text/plain' )
#    @cleanup.push( id )
#    
#    expires = Time.new()
#    expires += 3600
#    url = @esu.get_shareable_url( id, expires )
#    
#    uri = URI.parse( url )
#    io = uri.open()
#    
#    assert_equal( text, io.readlines, "object content wrong" )
#  end
#  
#  def test_read_object_stream() 
#    text = "The quick brown fox jumped over the lazy dog"
#    id = @esu.create_object( nil, nil, text, 'text/plain' )
#    @cleanup.push( id )
#    
#    io = @esu.read_object_stream( id )
#    assert_equal( text, io.readlines, "object content wrong" )
#  end
#  
#  def test_checksum()
#    text = "hello world"
#    
#    ck = EsuApi::Checksum.new( EsuApi::Checksum::SHA0 )
#    ck.update( text )
#    assert_equal( "SHA0/11/9fce82c34887c1953b40b3a2883e18850c4fa8a6", ck.to_s(), "Checkum test failed" )
#  end
#  
#  def test_create_checksum() 
#    ck = EsuApi::Checksum.new( EsuApi::Checksum::SHA0 )
#    ObjectId id = @esu.create_object( nil, nil, "hello world", "text/plain", ck );
#    @cleanup.push( id )
#  end
#  
#  def test_rename()
#    op1 = EsuApi::ObjectPath.new( '/' + randomstr( 8 ) )
#    op2 = EsuApi::ObjectPath.new( '/' + randomstr( 8 ) )
#    
#    id = @esu.create_object_on_path( op1, nil, nil, "hello world", "text/plain" )
#    @cleanup.push( id )
#    
#    # Rename it
#    @esu.rename( op1, op2 )
#    
#    # Check loading from new name
#    text = @esu.read_object( op2 )
#    
#    assert_equals( "hello world", text, "Renamed object content wrong" )
#  end
#  
#  def test_overwrite()
#    op1 = EsuApi::ObjectPath.new( '/' + randomstr( 8 ) )
#    op2 = EsuApi::ObjectPath.new( '/' + randomstr( 8 ) )
#    
#    id = @esu.create_object_on_path( op1, nil, nil, "hello world", "text/plain" )
#    @cleanup.push( id )
#    @esu.create_object_on_path( op2, nil, nil, "you shouldn't see me", "text/plain" )
#    
#    # Rename it and overwrite
#    @esu.rename( op1, op2, true )
#    
#    # Wait 5 seconds for server to overwrite object
#    sleep( 5 )
#    
#    # Check loading from new name
#    text = @esu.read_object( op2 )
#    
#    assert_equals( "hello world", text, "Renamed object content wrong" )
#  end
#      
#  
#  def test_get_service_information()
#    si = @esu.get_service_information()
#    
#    assert_not_nil( si.atmos_version, "Atmos version is nil" ) 
#  end
#  
#  # Tests readback with checksum verification.  In order to test this, create a policy
#  # with erasure coding and then set a policy selector with "policy=erasure" to invoke
#  # the erasure coding policy.
#  def test_read_checksum()
#    meta = {}
#    meta["policy"] = EsuApi::Metadata.new( "policy", "erasure", false )
#    ck = EsuApi::Checksum.new( EsuApi::Checksum::SHA0 )
#    id = @esu.create_object( nil, meta, "hello world", "text/plain", ck )
#    @cleanup.push( id )
#    
#    ck2 = EsuApi::Checksum.new( EsuApi::Checksum::SHA0 )
#    text = @esu.read_object( id, nil, nil, ck2 )
#    assert_equal( "hello world", text, "object content wrong" )
#    assert_equal( ck1.to_s(), ck2.to_s(), "checksums don't match" )
#    assert_equal( ck2.expected_value, ck2.to_s(), "checksum doesn't match expected value" )
#  end
#  
#  private
#
#  #
#  # Generate a random string that does not start or end with a space but can
#  # contain a space.
#  #
#  def randomstr( len )
#    chars = ("a".."z").to_a + ("A".."Z").to_a + ("0".."9").to_a + " ".to_a
#    endchars = ("a".."z").to_a + ("A".."Z").to_a + ("0".."9").to_a
#    newstr = ""
#    newstr << endchars[rand(endchars.size-1)]
#    2.upto(len-1) { |i| newstr << chars[rand(chars.size-1)] }
#    newstr << endchars[rand(endchars.size-1)]
#    return newstr
#  end
#
#  #
#  # Creates a file/stream with the given count of 
#  # random characters
#  #
#  def createTestStream( len )
#    tmpfile = Tempfile.new( "esutest" )
#    @cleanfiles.push( tmpfile )
#
#    tmpfile.open() do |aFile|
#      aFile << randomstr( len )
#    end
#
#    return tmpfile
#  end
#  
#  def createAcl
#    acl = []
#    
#    acl.push( EsuApi::Grant.new( EsuApi::Grantee( @uid, EsuApi::Grantee::USER ), EsuApi::Grant::FULL_CONTROL ) )
#    acl.push( EsuApi::Grant::OTHER, EsuApi::Grant::READ )  
#    
#    return acl
#  end
#  
#  # 
#  # Check to make sure that all the entries in acl1 exist
#  # in ACL2.  We do it this way because some Atmos servers
#  # are configured to add default grants to objects
#  #
#  def checkAcl( acl1, acl2 )
#    acl1.each { |entry| assert( acl2.include?(entry), "ACL entry" + entry + " not found in " + acl2 ) }
#  end
end