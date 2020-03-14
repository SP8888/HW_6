-- Пусть задан некоторый пользователь. 
-- Из всех друзей этого пользователя найдите человека, который больше всех общался с 
-- нашим пользователем.

-- добавил поля 
desc friendship ;
SELECT COUNT(user_id) FROM friendship GROUP BY friend_id ;
INSERT INTO friendship VALUES (30,8,1,NOW(),NOW());
INSERT INTO friendship VALUES (8,42,1,NOW(),NOW());
INSERT INTO friendship VALUES (74,8,1,NOW(),NOW());

desc messages; 

INSERT INTO messages VALUES (103,30,8,'qqqq0000',1,0,NOW());
SELECT * FROM messages WHERE from_user_id = 42;

-- Решение не стал выбирать друзей с потвержденым статусом, потому что таких мало (совсем не оказалось)
SELECT * FROM users WHERE id = 8;

SELECT COUNT(id) as 'количество сообщений',(SELECT CONCAT(first_name, ' ', last_name) 
      FROM users 
      WHERE id = to_user_id ) AS 'получатель', (SELECT CONCAT(first_name, ' ', last_name) 
      FROM users 
      WHERE id = from_user_id) AS 'отправитель' FROM messages WHERE from_user_id and to_user_id IN 
(
	(SELECT to_user_id FROM messages 
		WHERE from_user_id = 8 
		and to_user_id IN (SELECT user_id  FROM friendship WHERE user_id = 8 or friend_id = 8)
	)
	UNION
	(SELECT to_user_id FROM messages 
		WHERE from_user_id = 8 
		and to_user_id IN (SELECT friend_id FROM friendship WHERE user_id = 8 or friend_id = 8)
	) 
	UNION 
	(SELECT from_user_id FROM messages 
		WHERE to_user_id = 8 
		and from_user_id IN (SELECT user_id  FROM friendship WHERE user_id = 8 or friend_id = 8)
	)
	UNION 
	(SELECT from_user_id FROM messages 
		WHERE to_user_id = 8 
		and from_user_id IN (SELECT friend_id FROM friendship WHERE user_id = 8 or friend_id = 8)
	)
)
GROUP BY to_user_id , from_user_id 
order by 'количество сообщений' DESC
LIMIT 1;

-- Подсчитать общее количество лайков, которые получили 10 самых молодых пользователей.

SELECT user_id FROM profiles ORDER BY birthdate DESC LIMIT 10;
 



SELECT SUM(count_likes ) as sum_likes FROM (
 SELECT COUNT(*) AS count_likes 
  FROM likes 
    where target_type_id = (SELECT id FROM target_types WHERE name = 'users')
    AND likes.user_id IN 
    (SELECT * FROM (
SELECT user_id FROM profiles ORDER BY birthdate DESC LIMIT 10) as u
 	)
    GROUP BY target_id)
   as counted_likes;

   
   
-- Определить кто больше поставил лайков (всего) - мужчины или женщины?

SELECT COUNT(*) FROM likes ;
SELECT gender FROM profiles  ;

SELECT CASE(sex)
		WHEN 'm' THEN 'MAN'
		WHEN 'f' THEN 'WOMAN'
		END  as chose_sex,
		COUNT(*) as count_likes
		FROM 
		( SELECT user_id as u,
		(SELECT gender FROM profiles WHERE user_id = u ) as sex
		from likes ) as d_table
	group by chose_sex 
	ORDER by count_likes DESC
	;

-- Найти 10 пользователей, которые проявляют наименьшую активность в использовании социальной сети.
SELECT * FROM messages m ;

SELECT CONCAT(first_name, ' ', last_name) as u,
		(SELECT COUNT(*) FROM likes WHERE likes.user_id = users.id) +
		(SELECT COUNT(*) FROM media m2 WHERE m2.user_id = users.id) +
		(SELECT COUNT(*) FROM messages m3 WHERE m3.from_user_id  = users.id) as activity
	FROM users 
	ORDER BY activity LIMIT 10;
