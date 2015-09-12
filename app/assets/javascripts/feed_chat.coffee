add_unread = (data) ->
  if !$('td a#' + data.hashtag).children().hasClass('unread')
      $('td a#' + data.hashtag).append '<span class="badge badge-success unread">1</span>'
  else
    $('td a#' + data.hashtag + ' .unread').text (i, t) ->
      if t > 0
        Number(t) + 1
      else
        ''
add_feed_message = (data) ->
  console.log data
  #highlight = ''
  #if moment.utc(data.timestamp).isAfter()
  #  highlight = 'new_messages'

  like_icon_liked = ''
  star = 'star_border'
  if data.current_user_likes
    like_icon_liked = 'like-icon-liked'
    star = 'star'

  $('#feed').prepend ''+
    '<div class="feed-chat-box">' +
      '<a href="/users/' + data.user + '" class="avatar-link">' +
        '<img class="img-circle" src="' + data.avatar + '"></img>' +
      '</a>' +
      '<div class="message">' +
        '<h5>' +
          '<a href="/users/' + data.user + '">' + data.username + '</a>at ' +
          '<a href="/hashtags/' + data.hashtag_name + '">#' + data.hashtag_name + '</a>' +
          '<span class="timestamp">' + format_timestamp(data.timestamp) + '</span>' +
        '</h5>' +
        '<p>' +
          data.content +
          '<span class="space-left">' +
            '<span class="like-badge like-icon-color">' +
              data.likes +
            '</span>' +
            '<a class="send-hover like-this" href="#" id="like-' + data.id + '">' +
              '<i class="material-icons md-18 like-icon like-icon-color ' + like_icon_liked + '">' + star + '</i>' +
            '</a>' +
          '</span>' +
        '</p>' +
      '</div>' +
    '</div>'

    set_star_hover()

add_favourites_message = (data) ->
  if $('div.panel.fav#box-' + data.hashtag + ' .panel-body').length >= 5
    $('div.panel.fav#box-' + data.hashtag + ' .panel-body.fav:first').remove()

  $('div.panel.fav#box-' + data.hashtag).append ''+
    '<div class="panel-body fav">' +
      '<div class="favourites-chat-box">' +
        '<a href="/users/' + data.user + '" class="avatar-link">' +
          '<img class="img-circle" src="' + data.avatar + '"></img>' +
        '</a>' +
        '<div class="message">' +
          '<h5>' +
            '<a href="/users/' + data.user + '">' + data.username + '</a>at ' +
            '<a href="/hashtags/' + data.hashtag_name + '">#' + data.hashtag_name + '</a>' +
            '<br/>' +
            '<span class="timestamp">' + format_timestamp(data.timestamp) + '</span>' +
          '</h5>' +
          '<p>' + data.content + '</p>' +
        '</div>' +
      '</div>' +
    '</div>'

  $('#masonry-container').masonry()

add_message = (data) ->
  add_feed_message data
  add_favourites_message data

on_open = (socket) ->
  user = $('#user-id')[0].value

  socket.send JSON.stringify
    event: 'feed'
    user: user

on_message = (data) ->
  add_message data
  add_unread data

on_messages = (data) ->
  add_multiple_messages data, add_message, false

ready = ->
  if not $('#feed').length
    return
  else
    console.log('Feed page detected!')

  create_websocket {
    'open': on_open,
    'message': on_message,
    'notification': on_notification,
    'messages': on_messages
  }

exports = this
exports.add_feed_message = add_message

$(document).ready(ready)
$(document).on('page:load', ready)
