defmodule Donepezil do
  @moduledoc """
  Core module of pulling data from fb graph api
  """

  defstruct(
      id: "0",
      secret: "0",
      object_id: "0"
  )
  def init do
    client = %Donepezil{}
    client = %{client | id: IO.gets "App Id:"}
    client = %{client | secret: IO.gets "App secret:"}
    url = IO.gets "Post url:"
    client = %{client | object_id: createObjectId(url)}
    client
  end

  def memorize do
    client = init()
    imgList = readImageComments(client)
    File.mkdir("tmp")
    Enum.each(
      imgList,
      fn imgComment -> 
        downloadImage(imgComment.url, "tmp/"<>imgComment.id<>".jpg") 
      end
    )
  end

  def findFriendInComment do
    client = init()
    wordToFind = String.replace(IO.gets("word to find:"), "\n", "")
    fullPath = String.replace("https://graph.facebook.com/v2.8/"<> client.object_id <>"/comments/?access_token="<>client.id<>"|"<>client.secret, "\n", "")
    doFindWord(fullPath, wordToFind)
  end

  def getReactions do
    client = init()
    fullPath = String.replace("https://graph.facebook.com/v2.8/"<> client.object_id <>"/reactions/?access_token="<>client.id<>"|"<>client.secret, "\n", "")
    IO.puts fullPath
    all = doGetReactions(fullPath)
    Enum.each(
      all,
      fn v -> IO.puts v end
    )
    file = File.open! "tmp/reactions.csv", [:write]
    Enum.each(
      all,
      fn v -> IO.binwrite file, v<>"\n" end
    )
    File.close file
  end

  def doGetReactions(url) do
    resp = HTTPotion.get(url)
    {_,body} = Poison.decode(resp.body)
    list = Enum.map(
      body["data"],
      fn v -> v["id"] <> "," <> v["name"] <> "," <> v["type"] end
    )

    if body["paging"] && body["paging"]["next"] do
      IO.puts "read next page"
      list2 = doGetReactions(body["paging"]["next"])
      list = Enum.concat(list, list2)
    end
    list
  end
  
  def doFindWord(url, friend) do
    resp = HTTPotion.get(url)
    {_,body} = Poison.decode(resp.body)
    list = Enum.each(
      body["data"],
      fn v -> 
        {_,regex} = Regex.compile(friend)
        if Regex.match?(regex, v["message"]) do
          IO.puts v["id"]
          IO.puts v["message"]
        end
      end
    )
    #see if there is more
    if body["paging"] && body["paging"]["next"] do
      IO.puts "read next page"
      list2 = doFindWord(body["paging"]["next"], friend)
      list = Enum.concat(list, list2)
    end
  end

  def readImageComments(client) do
    fullpath = "https://graph.facebook.com/v2.8/" <> client.object_id <> "/comments?fields=attachment,from&access_token="<>client.id<>"|"<>client.secret
    fullpath = String.replace(fullpath, "\n", "")
    doReadComment(fullpath)
  end

  def doReadComment(fullpath) do
    IO.puts "GET "<>fullpath
    resp = HTTPotion.get(fullpath)
    {_,body} = Poison.decode(resp.body)
    list = Enum.filter_map(
      body["data"],
      fn v ->
        if v["attachment"] && v["attachment"]["media"] && v["attachment"]["media"]["image"] do
          :true
        end
      end,
      fn v ->
        %{"id": v["from"]["id"], "url": v["attachment"]["media"]["image"]["src"]}
      end
    )
    #see if there is more
    if body["paging"] && body["paging"]["next"] do
      IO.puts "read next page"
      list2 = doReadComment(body["paging"]["next"])
      list = Enum.concat(list, list2)
    end
    list
  end

  def createObjectId(url) do
    regex = ~r/https:\/\/www.facebook.com\/(?<pagename>.+)\/(?<type>.+)\/.*\/(?<objid>\d+)\//U
    captures = Regex.named_captures(regex, url)
    case captures["type"] do
      "photos" -> captures["objid"]
      "posts" -> getPageId(captures["pagename"]) <> "_" <> Integer.to_string(captures["objid"])
    end
  end

  def getPageId(pageName) do
    resp = HTTPotion.get("http://graph.facebook.com/v2.8/"<>pageName)
    resp.body["id"]
  end

  def downloadImage(imgUrl, saveLocation) do
    resp = HTTPotion.get imgUrl
    File.write(saveLocation, resp.body);
  end
end
