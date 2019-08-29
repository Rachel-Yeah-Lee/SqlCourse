--Workshop2
--N''�N��N��ƥ�unicode�s�X�A�w�]�OBig-5�Aunicode(�U��s�X�t��)�����h���r
/*1.�C�X�C�ӭɾ\�H�C�~�ɮѼƶq�A�ḙ̀ɾ\�H�s���M�~�װ��Ƨ�
Table�GBOOK_LEND_RECORD�BMEMBER_M */
USE [GSSWEB]
GO

SELECT	KEEPER_ID AS KeeperId,mm.USER_CNAME AS CName
		,mm.USER_ENAME AS EName
		,YEAR(LR.LEND_DATE) AS BorrowYear
		,COUNT(KEEPER_ID) AS BorrowCnt
FROM	BOOK_LEND_RECORD AS blr
		JOIN MEMBER_M AS mm ON KEEPER_ID = [USER_ID]
GROUP BY KEEPER_ID,mm.USER_CNAME,mm.USER_ENAME,YEAR(LEND_DATE)
ORDER BY KeeperId,YEAR(LR.LEND_DATE);

/*2.�C�X�̨��w�諸�ѫe���W(�ɾ\�ƶq�̦h�e���W)
Table�GBOOK_LEND_RECORD */
SELECT TOP(5)
		blr.BOOK_ID	AS BookId,bd.BOOK_NAME AS BookName
		,COUNT(bd.BOOK_ID)	AS QTY 
FROM BOOK_LEND_RECORD blr
	 JOIN BOOK_DATA bd ON blr.BOOK_ID = bd.BOOK_ID
GROUP BY blr.BOOK_ID,bd.BOOK_NAME
ORDER BY QTY DESC;
/*3.�H�@�u�C�X2019�~�C�@�u���y�ɾ\�Ѷq
Table�GBOOK_LEND_RECORD*/
SELECT  [Quarter],COUNT([Quarter]) AS Cnt
FROM	(SELECT 
			CASE
				WHEN DATEPART(QUARTER,LEND_DATE)= 1 THEN '2019-01~2019-03'
				WHEN DATEPART(QUARTER,LEND_DATE)= 2 THEN '2019-04~2019-06'
				WHEN DATEPART(QUARTER,LEND_DATE)= 3 THEN '2019-07~2019-09'
				WHEN DATEPART(QUARTER,LEND_DATE)= 4 THEN '2019-10~2019-12'
			END AS [Quarter]
		 FROM BOOK_LEND_RECORD 
		 WHERE YEAR(LEND_DATE)=2019
		 )blr
GROUP BY [Quarter]
ORDER BY [Quarter]
--�p�G2018�u�n���W�U�b�~�A2019�n���|�u�A�i�H�t�~�@��Ӹ�ƪ�A
--2018�~,1~6��,�W�b�~ \n 2018�~,7~12��,�U�b�~
--2019�~,1~3��,�Ĥ@�u \n 2019�~,4~6��,�ĤG�u \n 2019�~,7~9��,�ĤT�u \n 2019�~,10~12��,�ĥ|�u
--�̫�b�d�ߪ��ɭ�JOIN��ƪ�2018�M2019

/*4.���X�C�Ӥ����ɾ\�ƶq�e�T�W�ѥ��μƶq
Table�GBOOK_LEND_RECORD�BBOOK_CLASS*/
SELECT Seq 
	  ,BookClassName AS BookClass
	  ,BookId
	  ,BookName
	  ,Cnt
FROM 
	(SELECT ROW_NUMBER() OVER(PARTITION BY bd.BOOK_CLASS_ID ORDER BY COUNT(bd.BOOK_ID)DESC,bd.BOOK_ID) AS Seq
			,bd.BOOK_CLASS_ID AS BookClassId
			,bd.BOOK_ID AS BookId
			,bd.BOOK_NAME AS BookName
			,COUNT(bd.BOOK_ID)AS Cnt
			,bc.BOOK_CLASS_NAME AS	BookClassName
	  FROM BOOK_DATA bd 
		JOIN BOOK_LEND_RECORD blr ON bd.BOOK_ID=blr.BOOK_ID
		JOIN BOOK_CLASS bc ON bd.BOOK_CLASS_ID=bc.BOOK_CLASS_ID
	  GROUP BY bd.BOOK_CLASS_ID,bd.BOOK_NAME,bd.BOOK_ID,bc.BOOK_CLASS_NAME
	  )AS table1
WHERE table1.Seq<4
ORDER BY BookClass;
/*5.�ЦC�X 2016, 2017, 2018, 2019 �U���y���O���ɾ\�ƶq���
Table�GBOOK_LEND_RECORD*/
SELECT bc.BOOK_CLASS_ID AS ClassId,bc.BOOK_CLASS_NAME AS ClassName
	   ,SUM(blr.Cnt2016)AS Cnt2016,SUM(blr.Cnt2017)AS Cnt2017
	   ,SUM(blr.Cnt2018)AS Cnt2018,SUM(blr.Cnt2019)AS Cnt2019
FROM (SELECT BOOK_ID AS BookId
			,CASE 
				WHEN YEAR(LEND_DATE)=2016 THEN 1 ELSE 0
             END AS Cnt2016
			,CASE 
                WHEN YEAR(LEND_DATE)=2017 THEN 1 ELSE 0
             END AS Cnt2017
			,CASE 
                 WHEN YEAR(LEND_DATE)=2018 THEN 1 ELSE 0
             END AS Cnt2018
			,CASE 
				 WHEN YEAR(LEND_DATE)=2019 THEN 1 ELSE 0
             END AS Cnt2019
	  FROM BOOK_LEND_RECORD ) AS blr 
	  JOIN BOOK_DATA bd ON blr.BookId=bd.BOOK_ID
	  JOIN BOOK_CLASS bc ON bd.BOOK_CLASS_ID=bc.BOOK_CLASS_ID
GROUP BY bc.BOOK_CLASS_ID,bc.BOOK_CLASS_NAME
ORDER BY ClassId;

/*6.�Шϥ� PIVOT �y�k�C�X2016, 2017, 2018, 2019 �U���y���O���ɾ\�ƶq���
Table�GBOOK_LEND_RECORD
Sample�G�P�Ĥ��D*/
SELECT	 ClassId,ClassName
		,ISNULL([2016],0)AS [Cnt2016]
		,ISNULL([2017],0)AS[Cnt2017]
		,ISNULL([2018],0)AS[Cnt2018]
		,ISNULL([2019],0)AS[Cnt2019]
FROM	(SELECT bc.BOOK_CLASS_ID AS ClassId
				,bc.BOOK_CLASS_NAME AS ClassName
				,YEAR(blr.LEND_DATE) AS LEND_DATE
				,COUNT(bd.BOOK_ID)AS countBookId
		 FROM	BOOK_CLASS bc 
				JOIN BOOK_DATA bd  ON bc.BOOK_CLASS_ID=bd.BOOK_CLASS_ID
				JOIN BOOK_LEND_RECORD blr ON bd.BOOK_ID=blr.BOOK_ID
		 GROUP BY bc.BOOK_CLASS_ID,bc.BOOK_CLASS_NAME,(blr.LEND_DATE))AS GroupByLendDate
PIVOT	( SUM(BookId) For LEND_DATE
		  IN ([2016],[2017],[2018],[2019])) AS pvt
ORDER BY ClassId;


--�p�GPIVOT�̭��n��COUNT(LEND_DATE)�l�͸�ƪ�̭���LEND_DATE�N�n����YEAR(LEND_DATE)
--�]���o�˷|���C�@�Ѥ@��BookId���ɾ\�����A���O�p�G���@��BookId�b�@�Ѧ��⦸�ɾ\ �N�u�|��(COUNT)���@������
--�Ѫk:PIVOT�̭��令SUM(BookId)�N�i�H�ѨM�l�� ��ƪ�̭�����LEND_DATE�����O�~�שάO�骺���
--�]���l�͸�ƪ�̭����X�Ӫ��O�P�@���O�������P���(�~�שΤ骺)��BookId�ɾ\�ƶq
--�ҥH�bPIVOT�̭���⧹(COUNT)��BookId�ɾ\�ƶq�@�[�`(SUM)�N�i�H
--�H�~��GROUPBY(LEND_DATE):BookId�b�@�~�u�|���@��COUNT�A�H��GROUP BY(LEND_DATE):BookId�b�@�~�|���h��COUNT
--SUM()��C����Ƨ@�[�`�ACOUNT():�p���ƪ��C�ơAThat's,���e�ۦP����Ƥ]�|�W�߭p��

/*7.�Ьd�ߥX���|���ɮѬ����A�䤤�]�t�ѥ�ID�B�ʮѤ��(yyyy/mm/dd)�B�ɾ\���(yyyy/mm/dd)�B���y���O(id-name)�B�ɾ\�H(id-cname(ename))�B���A(id-name)�B�ʮѪ��B
Table�GBOOK_DATA�BBOOK_LEND_RECORD�BBOOK_CLASS�BBOOK_CODE*/
--�j�p�g�b�ݨD�W�i��|�����P���N��eg.mm�N��'��' MM�N��'��'�Ahh�N��'12�p�ɨ�(���W�U��)' HH�N��'24�p�ɨ�'
SELECT	bd.BOOK_ID AS '�ѥ�ID'
		,CONVERT(VARCHAR(100),bd.BOOK_BOUGHT_DATE,111) AS '�ʮѤ��'
		,CONVERT(VARCHAR(100),blr.LEND_DATE,111)AS '�ɾ\���'
		,CONCAT(bc.BOOK_CLASS_ID,'-',bc.BOOK_CLASS_NAME)AS '���y���O'
		,CONCAT(blr.KEEPER_ID,'-',M.USER_CNAME,'(',M.USER_ENAME,')')AS'�ɾ\�H'
		,CONCAT(bd.BOOK_STATUS,'-',bcode.CODE_NAME)AS'���A'
		,CONCAT(REPLACE(CONVERT(VARCHAR,CONVERT(MONEY,bd.BOOK_AMOUNT),1),'.00',''),'��')AS'�ʮѪ��B'
FROM	BOOK_DATA bd
		JOIN BOOK_LEND_RECORD blr ON bd.BOOK_ID=blr.BOOK_ID 
		JOIN BOOK_CODE bcode ON bcode.CODE_ID=bd.BOOK_STATUS
		JOIN BOOK_CLASS bc ON bc.BOOK_CLASS_ID=bd.BOOK_CLASS_ID
		JOIN MEMBER_M m ON M.[USER_ID]=blr.[KEEPER_ID]
WHERE	M.USER_CNAME='���|'
ORDER BY bd.BOOK_ID DESC;
/*8.�s�W�@���ɾ\�����A�ɮѤH�����|�A�ѥ�ID��2004�A�íק�ɾ\�����2019/01/02
Sample�G*/
BEGIN TRY
	BEGIN TRAN
	INSERT INTO dbo.BOOK_LEND_RECORD([BOOK_ID],[KEEPER_ID],[LEND_DATE],[CRE_DATE],[CRE_USR],[MOD_DATE],[MOD_USR])
	SELECT	bd.BOOK_ID,mm.[USER_ID],GETDATE(),GETDATE(),mm.[USER_ID],GETDATE(),mm.[USER_ID]
	FROM	MEMBER_M mm,BOOK_DATA bd
	WHERE	mm.USER_CNAME='���|' AND bd.BOOK_ID=2004;
	UPDATE dbo.BOOK_LEND_RECORD
	SET BOOK_LEND_RECORD.LEND_DATE='2019-01-02'
	FROM MEMBER_M mm
	 JOIN BOOK_LEND_RECORD blr ON mm.[USER_ID]=blr.KEEPER_ID
	WHERE mm.USER_CNAME='���|';
	COMMIT TRAN
END TRY
BEGIN CATCH
	SELECT ERROR_STATE()
	ROLLBACK TRAN
END CATCH


/*����|��BOOK_ID=2004���ѰO���R��*/
DELETE FROM dbo.BOOK_LEND_RECORD 
WHERE KEEPER_ID IN (SELECT [USER_ID]
					FROM	MEMBER_M mm
					WHERE	mm.USER_CNAME='���|')
	  AND BOOK_ID=2004;

SELECT *
FROM	BOOK_LEND_RECORD blr
WHERE	KEEPER_ID ='���|'
	  AND BOOK_ID=2004;

/*9.�бN�D9�s�W���ɾ\����(�ѥ�ID=2004)�R��*/
DELETE FROM BOOK_LEND_RECORD WHERE	--�p�G��WHERE��b�o��A�i�H�����ƫ���DELETE��ƪ�
		KEEPER_ID IN(SELECT [USER_ID]
							 FROM	MEMBER_M mm
							 WHERE mm.USER_CNAME='���|')
				AND BOOK_ID=2004;
