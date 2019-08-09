-- event
INSERT INTO c4u_event_source (name, struct) VALUES
    ('pwnable.kr', '{}'),
    ('ED CTF', '{}'),
    ('ksnctf', '{}');
INSERT INTO c4u_event (name, struct, event_source_id) VALUES
    ('pwnable.kr', '{"url":"http://pwnable.kr/index.php","dont_spoil":true}',
        (SELECT id FROM c4u_event_source WHERE name = 'pwnable.kr')),
    ('ED CTF', '{"url":"https://ctf.npca.jp/","download_link":"https://www.dropbox.com/sh/74yf95b0u6gsbkm/AAAGZLvHFMPdRXwkFChEU-3ta?dl=0","dont_spoil":true}',
        (SELECT id FROM c4u_event_source WHERE name = 'ED CTF')),
    ('ksnctf', '{"url":"http://ksnctf.sweetduet.info/","dont_spoil":true}',
        (SELECT id FROM c4u_event_source WHERE name = 'ksnctf'));

-- genre
INSERT INTO c4u_genre VALUES
    (1, 'pwn');

-- difficulty
INSERT INTO c4u_difficulty VALUES
    (1, 'baby', 1),
    (2, 'easy', 5),
    (3, 'medium easy', 10),
    (4, 'medium medium', 20),
    (5, 'medium hard', 30),
    (6, 'hard', 50);

-- tag
-- INSERT INTO tag ('name') VALUES
--     ('heap'),
--     ('katagaitai');
--
-- INSERT INTO chall_tag ('chall_id', 'tag_id') VALUES
--     (
--         (SELECT id FROM chall WHERE name = 'Breznparadisebugmaschine'),
--         (SELECT id FROM tag WHERE name = 'katagaitai')
--     ),
--     (
--         (SELECT id FROM chall WHERE name = 'beef_steak'),
--         (SELECT id FROM tag WHERE name = 'katagaitai')
--     ),
--     (
--         (SELECT id FROM chall WHERE name = 'Nokia 31337'),
--         (SELECT id FROM tag WHERE name = 'katagaitai')
--     ),
--     (
--         (SELECT id FROM chall WHERE name = 'stkof'),
--         (SELECT id FROM tag WHERE name = 'katagaitai')
--     ),
-- ;
